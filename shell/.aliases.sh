alias ..="cd .."

# batcat
alias cat="bat"
alias scat="bat --style=plain --paging=never"

# neovim
alias n="nvim"

# clipboard
if command -v win32yank.exe >/dev/null 2>&1; then
  alias cbi="win32yank.exe -i"
  alias cbo="win32yank.exe -o"
elif command -v xclip >/dev/null 2>&1; then
  alias cbi="xclip -selection clipboard -in"
  alias cbo="xclip -selection clipboard -out"
fi

# fzf
alias nlof="fzf_listoldfiles.sh"
alias fman="compgen -c | fzf | xargs man"
alias v="fd --hidden --type file --exclude .git | fzf-tmux -p --reverse | xargs nvim"

# eza
alias ls="eza --color=always --icons=always"
alias l="ls -la"

# tree
alias tree="tree -L 3 -a -I '.git' --charset X"
alias dtree="tree -L 3 -a -d -I '.git' --charset X"

# lazygit
alias lg="lazygit"

# zoxide
alias nzo="zoxide_openfiles_nvim.sh"
alias cd="z"

# yazi
alias y="yazi"

alias meteo="curl -s \"https://wttr.in/La%20Ciotat\""
