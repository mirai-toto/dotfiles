# Browser tools for OpenCode

`btools` is a short symlink to `~/.local/bin/browser-tools/browser-tools`, just
like `glf` points to `glab-failed-logs/glab-failed-logs`. Managed by chezmoi.
Requires Node.js 22.18+, npm, and OpenCode V2. Dependencies are pinned in
`package.json` and `package-lock.json`.

## Deploy and set up

From the public dotfiles repository:

```sh
chezmoi apply --source "$PWD" ~/.local/bin/browser-tools ~/.local/bin/btools
btools setup
```

This installs locked dependencies, downloads matching Chromium, runs the local
smoke test, and registers `playwright` globally with OpenCode. Re-running repairs
the installation and updates only the same named MCP entry.

`playwright` uses separate headless, isolated Chromium, not existing tabs or
logins. The launcher resolves Chromium's path from Playwright, rather than
hardcoding a revision. Downloads live in `~/.cache/ms-playwright`; screenshots
and snapshots live in `~/.local/bin/browser-tools/output/`.

If Linux browser libraries are missing, run
`~/.local/bin/browser-tools/node_modules/.bin/playwright install-deps chromium`
(may require sudo). The browser sandbox stays enabled.

## Test

```sh
btools test
# Optional external website check:
btools test https://opencode.ai
opencode mcp list
```

The default test serves a local page and checks navigation, reading, typing,
clicking, and screenshots without an external website. It closes the test browser
afterward; MCP starts its own browser on demand.

## Windows Chrome (existing tabs and logins)

Install the official [Playwright Extension](https://chromewebstore.google.com/detail/playwright-extension/mmlmfjhmonkocbjadbfplnigmagldckm)
in Windows Chrome, then run from WSL:

```sh
btools setup:chrome
```

Setup requires x64 Windows. It installs a pinned portable Windows Node.js from
nodejs.org, verifies its published SHA-256 checksum, and installs locked MCP
packages in `%LOCALAPPDATA%\browser-tools`. No admin installation, Windows PATH
changes, Chrome remote-debugging flags, or extension token are needed. MCP uses
standard input/output through WSL; no separate HTTP server is exposed.

The second global MCP entry is `chrome`; `playwright` remains unchanged. Approve
the connection in Chrome and share only the tabs needed for the task. The agent
can read private content and act as your logged-in account; page content may
reach your model provider. Disconnect through the extension when finished.

Do not configure `PLAYWRIGHT_MCP_EXTENSION_TOKEN`: it bypasses approval. The
launcher unsets it to retain manual approval. Screenshots and snapshots go to
`%LOCALAPPDATA%\browser-tools\output`. If several profiles have the extension,
Playwright uses the last-used one; add `--profile-dir-name "Profile 2"` to the
managed `executable_chrome.sh` to select a profile (see `chrome://version`).

Re-run `setup:chrome` to repair or after dependency updates. Update the managed
`node-windows.version` explicitly when upgrading the Windows runtime.

## Update dependencies

Update the deployed installation, then save the manifests back to dotfiles:

```sh
cd ~/.local/bin/browser-tools
npm install --save-exact @playwright/mcp@latest
npm install --save-exact "playwright@$(node -p "require('./node_modules/@playwright/mcp/package.json').dependencies.playwright")"
btools setup
# If using Windows Chrome:
btools setup:chrome
```

From the public dotfiles repository, persist the new versions:

```sh
./save.sh ~/.local/bin/browser-tools/package.json ~/.local/bin/browser-tools/package-lock.json
```

Keep both manifests committed for reproducible reinstalls. Do not save
`node_modules/` or `output/` into dotfiles.

## Migrate from the old standalone directory

Deploy and run both setup commands above for the MCP servers you use. They
replace the old `~/browser-tools` launcher paths with the managed local bin
paths. The old directory is no longer needed after verification; setup does not
delete it.

## Disconnect

Use `/mcps` in OpenCode to inspect or disconnect either server. To permanently
unregister it, remove only `mcp.servers.playwright` or `mcp.servers.chrome` from
`~/.config/opencode/opencode.jsonc`.
