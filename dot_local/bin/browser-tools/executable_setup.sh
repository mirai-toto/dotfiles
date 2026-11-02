#!/usr/bin/env bash
set -euo pipefail

root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$root"
npm ci
./node_modules/.bin/playwright install chromium --no-shell
npm test
opencode mcp add playwright --global -- "$(command -v node)" -- "$root/mcp.ts"
cd "$HOME"
opencode mcp list
