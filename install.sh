#!/bin/bash

SCRIPT_DIR=$(dirname "$(realpath "$0")")

install_homebrew() {
  if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
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



install_flutter() {
  local flutter_dir="$HOME/.local/share/flutter"
  if [ -d "$flutter_dir" ]; then
    echo "Flutter is already installed at $flutter_dir. Skipping."
  else
    echo "Installing Flutter..."
    mkdir -p "$HOME/.local/share"
    git clone https://github.com/flutter/flutter.git "$flutter_dir" --branch stable --depth 1
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

print_completion_message() {
  echo "Dotfiles applied."
  echo -e "\033[33mNext:\033[0m run dotfiles-private/install.sh to deploy secrets and git identity."
  echo -e "\033[31mTo apply the changes:\033[0m close and reopen your terminal."
}

# Main
install_homebrew
ensure_local_bin
install_utilities
apply_dotfiles
change_default_shell_to_zsh
setup_tmux_plugin_manager
install_flutter
fix_wsl_etc_environment
print_completion_message
