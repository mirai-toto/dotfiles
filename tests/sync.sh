#!/bin/bash
# Isolated command-order and failure tests; no real Git, secrets, or deployment.
# Usage: bash tests/sync.sh [private-repo ...]
set -euo pipefail

public_repo=$(dirname "$(dirname "$(realpath "$0")")")
temporary=$(mktemp -d "${TMPDIR:-/tmp/opencode}/dotfiles-sync-test.XXXXXX")
trap 'rm -rf -- "$temporary"' EXIT
export HOME="$temporary/home" TRACE="$temporary/trace" STATE="$temporary/state"
mkdir -p "$HOME/.config/chezmoi/profiles" "$temporary/bin" "$STATE"
export PATH="$temporary/bin:$PATH"

cat > "$temporary/bin/git" <<'EOF'
#!/bin/bash
set -euo pipefail
shift 2 # -C repo
if [ "${1:-}" = -c ]; then shift 2; fi
printf 'git %s\n' "$*" >> "$TRACE"
case "$1" in
diff)
  if [ "${STAGED:-0}" = 1 ]; then exit 1; fi
  if [ -f "$STATE/captured" ] && [ "${CHANGED:-1}" = 1 ]; then exit 1; fi
  ;;
rev-parse) exit "${NO_UPSTREAM:-0}" ;;
rev-list) echo "${AHEAD:-0}" ;;
pull) exit "${PULL_FAIL:-0}" ;;
push) exit "${PUSH_FAIL:-0}" ;;
esac
EOF

cat > "$temporary/bin/chezmoi" <<'EOF'
#!/bin/bash
set -euo pipefail
while [ "${1:-}" = --config ] || [ "${1:-}" = --source ]; do shift 2; done
printf 'chezmoi %s\n' "$1" >> "$TRACE"
case "$1" in
re-add)
  touch "$STATE/captured"
  exit "${CAPTURE_FAIL:-0}"
  ;;
managed) printf 'managed-file\0' ;;
apply) exit "${APPLY_FAIL:-0}" ;;
source-path) echo /managed-file ;;
esac
EOF

cat > "$temporary/bin/opencode" <<'EOF'
#!/bin/bash
printf 'opencode %s\n' "$*" >> "$TRACE"
EOF
chmod +x "$temporary/bin/"*

reset_case() {
  : > "$TRACE"
  rm -f "$STATE/captured"
  unset STAGED CHANGED NO_UPSTREAM AHEAD PULL_FAIL PUSH_FAIL CAPTURE_FAIL APPLY_FAIL
}

assert_absent() {
  if grep -q -- "$1" "$TRACE"; then
    echo "Unexpected command: $1" >&2
    cat "$TRACE" >&2
    exit 1
  fi
}

expect_failure() {
  if bash "$@" > "$temporary/output" 2>&1; then
    echo "Expected failure: $*" >&2
    exit 1
  fi
}

for source_repo in "$public_repo" "$@"; do
  repo="$temporary/repo"
  mkdir -p "$repo/scripts"
  cp "$source_repo/publish.sh" "$source_repo/apply.sh" "$repo/"
  if [ -f "$source_repo/scripts/profile.sh" ]; then
    cp "$source_repo/scripts/profile.sh" "$repo/scripts/"
    printf 'test-profile\n' > "$repo/profile-id"
    touch "$HOME/.config/chezmoi/profiles/test-profile.toml"
  else
    rm -f "$repo/scripts/profile.sh" "$repo/profile-id"
  fi

  reset_case
  bash "$repo/publish.sh" > "$temporary/output" 2>&1
  # Verify capture precedes commit, which precedes pull and push.
  grep -E '^(chezmoi re-add|git commit|git pull|git push)' "$TRACE" > "$temporary/order"
  cat > "$temporary/expected" <<'EOF'
chezmoi re-add
git commit -m chore(dotfiles): sync managed files
git pull --rebase --no-autostash
git push
EOF
  diff -u "$temporary/expected" "$temporary/order"

  reset_case
  export CHANGED=0
  bash "$repo/publish.sh" > "$temporary/output" 2>&1
  assert_absent 'git commit'
  grep -q '^git pull --rebase --no-autostash$' "$TRACE"
  grep -q '^git push$' "$TRACE"

  for failure in STAGED NO_UPSTREAM AHEAD CAPTURE_FAIL; do
    reset_case
    export "$failure=1"
    expect_failure "$repo/publish.sh"
    assert_absent 'git pull'
    assert_absent 'git push'
  done

  reset_case
  export PULL_FAIL=1
  expect_failure "$repo/publish.sh"
  grep -q '^git commit' "$TRACE"
  assert_absent 'git push'

  reset_case
  export PUSH_FAIL=1
  expect_failure "$repo/publish.sh"

  reset_case
  bash "$repo/apply.sh" > "$temporary/output" 2>&1
  grep -q '^chezmoi apply' "$TRACE"
  assert_absent '^git '

  reset_case
  export APPLY_FAIL=1
  expect_failure "$repo/apply.sh"
  assert_absent '^git '
  assert_absent '^opencode '
  echo "PASS: $source_repo publish/apply"
done

# Test discovery, both action names, and stopping after a profile failure.
reset_case
mkdir -p "$HOME/.config/dotfiles/profiles.d" "$temporary/public" "$temporary/private"
printf 'sourceDir = "%s/public"\n' "$temporary" > "$HOME/.config/chezmoi/chezmoi.toml"
printf 'test-profile\n' > "$temporary/private/profile-id"
ln -s "$temporary/private" "$HOME/.config/dotfiles/profiles.d/test-profile"
for repo in "$temporary/public" "$temporary/private"; do
  for action in publish apply; do
    cat > "$repo/$action.sh" <<'EOF'
#!/bin/bash
printf '%s/%s\n' "$(basename "$(dirname "$0")")" "$(basename "$0")" >> "$TRACE"
exit "${ACTION_FAIL:-0}"
EOF
  done
done
for action in publish apply; do
  reset_case
  bash "$public_repo/private_dot_local/bin/executable_dotfiles-sync" "$action"
  printf 'public/%s.sh\nprivate/%s.sh\n' "$action" "$action" > "$temporary/expected"
  diff -u "$temporary/expected" "$TRACE"
done
reset_case
export ACTION_FAIL=1
expect_failure "$public_repo/private_dot_local/bin/executable_dotfiles-sync" publish
assert_absent 'private/'
unset ACTION_FAIL
reset_case
expect_failure "$public_repo/private_dot_local/bin/executable_dotfiles-sync" save
test ! -s "$TRACE"
echo 'PASS: dotfiles-sync discovery, actions, and failure handling'
