#!/bin/bash

SCRIPT_DIR=$(dirname "$(realpath "$0")")

ensure_local_bin() {
  if [ ! -d "$HOME/.local/bin" ]; then
    mkdir -p "$HOME/.local/bin"
  fi
  export PATH="$HOME/.local/bin:$PATH"
}

install_homebrew() {
  echo "Installing Homebrew..."
  if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    echo "Homebrew is already installed."
  fi

  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

  if ! grep -q 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' ~/.profile; then
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >>~/.profile
    echo "Added Homebrew initialization to ~/.profile."
  else
    echo "Homebrew initialization already present in ~/.profile."
  fi

  if brew analytics state | grep -q "enabled"; then
    brew analytics off
  fi
}

install_utilities() {
  install_homebrew
  echo "Installing utilities..."
  brew bundle --file="$SCRIPT_DIR/Brewfile"
}

change_default_shell_to_zsh() {
  if [ -x "/home/linuxbrew/.linuxbrew/bin/zsh" ]; then
    echo "Changing default shell to Homebrew's Zsh..."
    if ! grep -Fxq "/home/linuxbrew/.linuxbrew/bin/zsh" /etc/shells; then
      echo "/home/linuxbrew/.linuxbrew/bin/zsh" | sudo tee -a /etc/shells
    fi
    echo "Please enter your password to change the default shell."
    if sudo chsh -s /home/linuxbrew/.linuxbrew/bin/zsh "$USER"; then
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

print_completion_message() {
  echo "Dotfiles applied."
  echo -e "\033[33mDon't forget to fill in:\033[0m"
  echo -e "  - \033[33m~/.gitconfig.local\033[0m  (git name and email)"
  echo -e "  - \033[33m~/.secrets\033[0m           (API keys and other secrets)"
  echo -e "\033[31mTo apply the changes:\033[0m"
  echo -e "- Close and reopen your terminal."
}

# Main
ensure_local_bin
install_utilities
apply_dotfiles
change_default_shell_to_zsh
setup_tmux_plugin_manager
setup_secrets
setup_git_local
print_completion_message
