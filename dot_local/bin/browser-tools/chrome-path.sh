#!/usr/bin/env bash
# Shared by the setup and MCP launcher. Windows paths are resolved per user.
windows_local="$(powershell.exe -NoProfile -NonInteractive -Command '[Console]::WriteLine($env:LOCALAPPDATA)' </dev/null | tr -d '\r')"
windows_root="${windows_local}\\browser-tools"
chrome_root="$(wslpath -u "$windows_root")"
