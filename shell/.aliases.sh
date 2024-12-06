alias ..="cd .."

# batcat
alias cat="bat"
alias scat="bat --style=plain --paging=never"

# neovim
alias n="nvim"

# clipboard
alias cbi="win32yank.exe -i"
alias cbo="win32yank.exe -o"

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

# ripgrep
alias rg="ripgrep"

# yazi
alias y="yazi"

alias meteo="curl -s \"https://wttr.in/La%20Ciotat\""
