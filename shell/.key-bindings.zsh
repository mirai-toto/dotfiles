# Ensure terminal is in application mode when zle is active
function zle-line-init() {
  echoti smkx
}
function zle-line-finish() {
  echoti rmkx
}
zle -N zle-line-init
zle -N zle-line-finish

# Use emacs key bindings
bindkey -e

# History navigation
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[5~" up-line-or-history           # [PageUp] - Up a line of history
bindkey "^[[6~" down-line-or-history         # [PageDown] - Down a line of history
bindkey "^[[A" up-line-or-beginning-search   # Start typing + [Up-Arrow] - fuzzy find history forward
bindkey "^[[B" down-line-or-beginning-search # Start typing + [Down-Arrow] - fuzzy find history backward
bindkey '^p' history-search-backward         # [Ctrl-p] - Search history backward
bindkey '^n' history-search-forward          # [Ctrl-n] - Search history forward

# Line navigation
bindkey "^[[H" beginning-of-line # [Home] - Go to beginning of line
bindkey "^[[F" end-of-line       # [End] - Go to end of line

# Completion navigation
bindkey "^[[Z" reverse-menu-complete # [Shift-Tab] - move through the completion menu backwards

# Character deletion
bindkey '^?' backward-delete-char  # [Backspace] - delete backward
bindkey "^[[3~" delete-char        # [Delete] - delete forward
bindkey '^[[3;5~' kill-word        # [Ctrl-Delete] - delete whole forward-word
bindkey \^U backward-kill-line     # [Ctrl-u] - Delete line backward from the cursor

# Word navigation
WORDCHARS='*?_-.[]~=/&;!#$%^(){}<>' # Customize word boundaries
bindkey '^[[1;5C' forward-word      # [Ctrl-RightArrow] - move forward one word
bindkey '^[[1;5D' backward-word     # [Ctrl-LeftArrow] - move backward one word

# Magic space
bindkey ' ' magic-space # [Space] - don't do history expansion

# Region and line editing
bindkey '\ew' kill-region            # [Esc-w] - Kill from the cursor to the mark
bindkey '\el' 'ls\n'                 # [Esc-l] - run command: ls
bindkey '^r' history-incremental-search-backward # [Ctrl-r] - Search backward incrementally
bindkey '\^K' kill-line                            # [Ctrl-k] - Delete line forward from the cursor 
 
# [Ctrl-x] [Ctrl-e]  Edit the current command line in $EDITOR
autoload -U edit-command-line
zle -N edit-command-line
bindkey '\C-x\C-e' edit-command-line

# Copy Previous Shell Word
bindkey "^[m" copy-prev-shell-word
