#!/usr/bin/env bash
set -euo pipefail
root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$root/chrome-path.sh"
version="$(cat "$root/node-windows.version")"
unset PLAYWRIGHT_MCP_EXTENSION_TOKEN
cd "$chrome_root"
exec "$chrome_root/runtime/node-${version}.exe" \
  "${windows_root}\\node_modules\\@playwright\\mcp\\cli.js" \
  --extension --browser chrome --output-dir "${windows_root}\\output"
