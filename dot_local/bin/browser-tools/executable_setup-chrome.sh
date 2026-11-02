#!/usr/bin/env bash
set -euo pipefail
root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$root/chrome-path.sh"
version="$(cat "$root/node-windows.version")"
architecture="$(powershell.exe -NoProfile -NonInteractive -Command '[Console]::WriteLine($env:PROCESSOR_ARCHITECTURE)' | tr -d '\r')"
if [[ "$architecture" != AMD64 ]]; then
  echo "This setup currently requires x64 Windows." >&2
  exit 1
fi

mkdir -p "$chrome_root/runtime" "$chrome_root/output"
runtime="$chrome_root/runtime/node-${version}.exe"
checksums="$chrome_root/runtime/SHASUMS256-${version}.txt"
curl --silent --show-error --fail --location --retry 3 "https://nodejs.org/dist/$version/SHASUMS256.txt" -o "$checksums"
expected="$(awk '$2 == "win-x64/node.exe" { print $1 }' "$checksums")"
if [[ ! "$expected" =~ ^[a-f0-9]{64}$ ]]; then
  echo "Missing Node.js checksum; refusing download." >&2
  exit 1
fi
if [[ ! -f "$runtime" ]] || ! printf '%s  %s\n' "$expected" "$runtime" | sha256sum --check --status; then
  curl --silent --show-error --fail --location --retry 3 "https://nodejs.org/dist/$version/win-x64/node.exe" -o "$runtime.download"
  printf '%s  %s\n' "$expected" "$runtime.download" | sha256sum --check
  mv "$runtime.download" "$runtime"
fi

chmod u+x "$runtime"
cp "$root/package.json" "$root/package-lock.json" "$chrome_root/"
npm ci --prefix "$chrome_root" --ignore-scripts --no-bin-links
"$runtime" --version
"$runtime" "${windows_root}\\node_modules\\@playwright\\mcp\\cli.js" --version
opencode mcp add chrome --global -- "$(command -v bash)" "$root/chrome.sh"
cd "$HOME"
opencode mcp list
