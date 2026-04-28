#!/bin/bash

SCRIPT_DIR=$(dirname "$(realpath "$0")")

check_homebrew() {
  if ! command -v brew &>/dev/null; then
    echo "Error: Homebrew is not installed. Please install it before running this script." >&2
    exit 1
  fi
}

ensure_local_bin() {
  if [ ! -d "$HOME/.local/bin" ]; then
    mkdir -p "$HOME/.local/bin"
  fi
  export PATH="$HOME/.local/bin:$PATH"
}

install_utilities() {
  echo "Installing utilities..."
  brew bundle --file="$SCRIPT_DIR/Brewfile"
}

change_default_shell_to_zsh() {
  if [ -x "$(brew --prefix)/bin/zsh" ]; then
    echo "Changing default shell to Homebrew's Zsh..."
    if ! grep -Fxq "$(brew --prefix)/bin/zsh" /etc/shells; then
      echo "$(brew --prefix)/bin/zsh" | sudo tee -a /etc/shells
    fi
    echo "Please enter your password to change the default shell."
    if sudo chsh -s "$(brew --prefix)/bin/zsh" "$USER"; then
      echo "Default shell successfully changed to Homebrew's Zsh."
    else
      echo "Failed to change the default shell. Please check your permissions or configuration."
      exit 1
    fi
  else
    echo "Homebrew's Zsh is not installed or not executable. Skipping shell change."
  fi
}

apply_dotfiles() {
  echo "Applying dotfiles with chezmoi..."
  mkdir -p "$HOME/.config/chezmoi"
  cat >"$HOME/.config/chezmoi/chezmoi.toml" <<EOF
[chezmoi]
  sourceDir = "$SCRIPT_DIR"
EOF
  chezmoi apply --source "$SCRIPT_DIR"
}

setup_tmux_plugin_manager() {
  if [ ! -d "$HOME/.config/tmux/plugins/tpm" ]; then
    echo "Cloning TPM..."
    mkdir -p "$HOME/.config/tmux/plugins"
    git clone https://github.com/tmux-plugins/tpm "$HOME/.config/tmux/plugins/tpm"
  else
    echo "TPM is already installed."
  fi
}

setup_secrets() {
  if [ ! -f "$HOME/.secrets" ]; then
    echo "Creating ~/.secrets from template..."
    cp "$SCRIPT_DIR/secrets.example" "$HOME/.secrets"
    echo "Fill in your secrets at ~/.secrets"
  else
    echo "~/.secrets already exists. Skipping."
  fi
}

setup_git_local() {
  if [ ! -f "$HOME/.gitconfig.local" ]; then
    echo "Creating ~/.gitconfig.local from template..."
    cp "$SCRIPT_DIR/gitconfig_local.example" "$HOME/.gitconfig.local"
    echo "Fill in your git identity at ~/.gitconfig.local"
  else
    echo "~/.gitconfig.local already exists. Skipping."
  fi
}

fix_wsl_etc_environment() {
  if grep -qi microsoft /proc/version 2>/dev/null; then
    if grep -q '^PATH=' /etc/environment; then
      echo "Removing static PATH from /etc/environment (restores WSL Windows path injection)..."
      sudo sed -i '/^PATH=/d' /etc/environment
    fi
  fi
}

setup_git_work() {
  if [ ! -f "$HOME/.gitconfig.work" ]; then
    echo "Creating ~/.gitconfig.work from template..."
    cp "$SCRIPT_DIR/gitconfig_work.example" "$HOME/.gitconfig.work"
    echo "Fill in your work git identity at ~/.gitconfig.work"
  else
    echo "~/.gitconfig.work already exists. Skipping."
  fi
}

print_completion_message() {
  echo "Dotfiles applied."
  echo -e "\033[33mDon't forget to fill in:\033[0m"
  echo -e "  - \033[33m~/.gitconfig.local\033[0m  (git name and email)"
  echo -e "  - \033[33m~/.gitconfig.work\033[0m   (work git name and email)"
  echo -e "  - \033[33m~/.secrets\033[0m           (API keys and other secrets)"
  echo -e "\033[31mTo apply the changes:\033[0m"
  echo -e "- Close and reopen your terminal."
}

# Main
check_homebrew
ensure_local_bin
install_utilities
apply_dotfiles
change_default_shell_to_zsh
setup_tmux_plugin_manager
setup_secrets
setup_git_local
setup_git_work
fix_wsl_etc_environment
print_completion_message
