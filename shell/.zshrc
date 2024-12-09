# Powerlevel10k Instant Prompt (should stay at the top)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Environment Variables
export ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"
export FZF_DEFAULT_OPTS="--height 50% --layout=default --border --color=hl:#2dd4bf"
export FZF_TMUX_OPTS=" -p90%,70% "
export TMUX_CONF=~/.config/tmux/.tmux.conf
export EDITOR='nvim'

# History Settings
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_find_no_dups

# Initialization Scripts
source ~/.profile

# Zinit Setup (Download if missing)
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# Plugins via Zinit
zinit ice depth=1; zinit light romkatv/powerlevel10k
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Completion Settings
autoload -U compinit && compinit
zstyle ':completion:*' menu no
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format "$fg[yellow]%B--- %d%b"
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format "$fg[red]No matches for:$reset_color %d"
zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
zstyle ':completion:*' group-name ''

#### Key Bindings ####

source ~/.key-bindings.zsh

#### Aliases ####

# batcat
alias cat="batcat"
alias scat="batcat --style=plain --paging=never"

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
alias ll="ls -l"

# tree
alias tree="tree -L 3 -a -I '.git' --charset X "
alias dtree="tree -L 3 -a -d -I '.git' --charset X "

# lazygit
alias lg="lazygit"

# tmux
alias tmux="tmux -f $TMUX_CONF"

# zoxide
alias nzo="zoxide_openfiles_nvim.sh"

# ripgrep
alias rg="ripgrep"

# yazi
alias y="yazi"

# fzf Integration
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
eval "$(fzf --zsh)"

# zoxide Integration
eval "$(zoxide init zsh)"

# Function to Start TMUX After Initialization
zsh_after_init() {
  if [ -z "$TMUX" ] && [ "$USE_TMUX" = "true" ]; then
    tmux -f $TMUX_CONF attach || tmux -f $TMUX_CONF new
  fi
}

# Hook to Run the Function After Initialization
autoload -Uz add-zsh-hook
add-zsh-hook -Uz precmd zsh_after_init

# Powerlevel10k Configuration
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
