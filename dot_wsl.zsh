# WSL2 + systemd doesn't propagate WSL_INTEROP to user sessions; find it via pstree
if [[ -z "$WSL_INTEROP" ]] && [[ -d /run/WSL ]]; then
  for _wsl_pid in $(pstree -np -s $$ | grep -o -E '[0-9]+'); do
    if [[ -e "/run/WSL/${_wsl_pid}_interop" ]]; then
      export WSL_INTEROP="/run/WSL/${_wsl_pid}_interop"
      break
    fi
  done
  unset _wsl_pid
fi

# tmux may inherit a PATH without Windows applications; recover the VS Code launcher.
# Keep an existing code command and support both per-user and system-wide installs.
if [[ -d /mnt/c/Windows/System32 ]] && ! command -v code >/dev/null 2>&1; then
  for _wsl_code_bin in \
    /mnt/c/Users/*/AppData/Local/Programs/"Microsoft VS Code"/bin(N) \
    "/mnt/c/Program Files/Microsoft VS Code/bin" \
    "/mnt/c/Program Files (x86)/Microsoft VS Code/bin"; do
    if [[ -x "$_wsl_code_bin/code" ]]; then
      export PATH="$PATH:$_wsl_code_bin"
      break
    fi
  done
  unset _wsl_code_bin
fi

# /etc/environment overwrites WSL's Windows path injection; re-add if missing
if [[ -d "/mnt/c/Windows/System32" ]] && [[ ":$PATH:" != *":/mnt/c/Windows/System32:"* ]]; then
  export PATH="$PATH:/mnt/c/Windows/System32:/mnt/c/Windows:/mnt/c/Windows/System32/Wbem:/mnt/c/Windows/System32/WindowsPowerShell/v1.0/"
fi
