# Powerlevel10k Instant Prompt (should stay at the top)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#### profile ####
[[ -f ~/.profile ]] && source ~/.profile

#### Key Bindings ####
source ~/.key-bindings.zsh

#### Aliases ####
source ~/.aliases.sh

# Environment Variables

USE_TMUX=true

export SHELL="/home/linuxbrew/.linuxbrew/bin/zsh"
export XDG_CONFIG_HOME="$HOME/.config"
export PATH="$HOME/.local/bin:$PATH"
export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
export EDITOR='nvim'
export ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

FZF_OPTS_WITH_BATCAT_AND_TREE="--preview 'if test -d {}; then tree -L 3 -a -I \".git\" --charset X {}; else bat --color always {}; fi'"

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"
export FZF_DEFAULT_OPTS=" --height 50% --layout=default --border --color=hl:#2dd4bf"
export FZF_CTRL_T_OPTS="$FZF_OPTS_WITH_BATCAT_AND_TREE"
export FZF_ALT_C_OPTS="$FZF_OPTS_WITH_BATCAT_AND_TREE"
export FZF_TMUX_OPTS=" -p90%,70% "

export LANG=en_US.UTF-8

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

# Zinit Setup (Download if missing)
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# Plugins via Zinit
zinit ice depth=1; zinit light romkatv/powerlevel10k
zinit light zsh-users/zsh-syntax-highlighting

zinit ice \
    atclone'[[ ! -f src/_docker ]] && docker completion zsh > src/_docker' \
    atpull'[[ ! -f src/_docker ]] && docker completion zsh > src/_docker' \
    atload'[[ ! -L ~/.local/share/zinit/completions/_docker ]] && ln -s $PWD/src/_docker ~/.local/share/zinit/completions/_docker' \
    as"completion"
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zinit snippet OMZP::git

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

# fzf Integration
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
eval "$(fzf --zsh)"

# zoxide Integration
eval "$(zoxide init zsh)"

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Function to Start TMUX After Initialization
zsh_after_init() {
  if [ -z "$TMUX" ] && [ "$USE_TMUX" = "true" ]; then
    tmux attach || tmux new
  fi
}

# Hook to Run the Function After Initialization
autoload -Uz add-zsh-hook
add-zsh-hook -Uz precmd zsh_after_init

# Powerlevel10k Configuration
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
