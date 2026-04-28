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

# /etc/environment overwrites WSL's Windows path injection; re-add if missing
if [[ -d "/mnt/c/Windows/System32" ]] && [[ ":$PATH:" != *":/mnt/c/Windows/System32:"* ]]; then
  export PATH="$PATH:/mnt/c/Windows/System32:/mnt/c/Windows:/mnt/c/Windows/System32/Wbem:/mnt/c/Windows/System32/WindowsPowerShell/v1.0/"
fi
