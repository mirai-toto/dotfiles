#!/bin/bash

SCRIPT_DIR=$(dirname "$(realpath "$0")")

ensure_local_bin() {
  if [ ! -d "$HOME/.local/bin" ]; then
    echo "Creating $HOME/.local/bin directory..."
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
  cat > "$HOME/.config/chezmoi/chezmoi.toml" << EOF
[chezmoi]
  sourceDir = "$SCRIPT_DIR"
EOF
  chezmoi apply --source "$SCRIPT_DIR"
}

setup_tmux_plugin_manager() {
  if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "Cloning TPM..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  else
    echo "TPM is already installed."
  fi
}

configure_locale() {
  echo "Configuring locale..."
  if ! locale -a | grep -q "en_US.utf8"; then
    sudo locale-gen en_US.UTF-8
    sudo update-locale LANG=en_US.UTF-8
    echo "Locale en_US.UTF-8 configured successfully."
  else
    echo "Locale en_US.UTF-8 is already configured."
  fi
}

install_wt_settings() {
  if [ -z "$WSL_DISTRO_NAME" ]; then
    echo "Not running inside WSL. Skipping wt-settings installation."
    return
  fi

  echo "Installing wt-settings..."
  if [ ! -d "$HOME/.local/src/wt-settings" ]; then
    mkdir -p "$HOME/.local/src"
    git clone https://github.com/mirai-toto/wt-settings.git "$HOME/.local/src/wt-settings"
  else
    echo "wt-settings already cloned."
  fi
  uv tool install -e "$HOME/.local/src/wt-settings"
}


setup_secrets() {
  if [ ! -f "$HOME/.secrets" ]; then
    echo "Creating ~/.secrets from template..."
    cp "$SCRIPT_DIR/.secrets.example" "$HOME/.secrets"
    echo "Fill in your secrets at ~/.secrets"
  else
    echo "~/.secrets already exists. Skipping."
  fi
}

configure_wsl_terminal_profile() {
  if [ -z "$WSL_DISTRO_NAME" ]; then
    echo "Not running inside WSL. Skipping Windows Terminal profile configuration."
    return
  fi

  echo "Configuring Windows Terminal profile '$WSL_DISTRO_NAME'..."
  wts profile font "$WSL_DISTRO_NAME" --face "DroidSansM Nerd Font Mono"
  wts profile opacity "$WSL_DISTRO_NAME" 80 --acrylic
  wts profile bell "$WSL_DISTRO_NAME" --disable
  wts scheme apply "$WSL_DISTRO_NAME" "Dark+"
}

print_completion_message() {
  echo -e "\033[31mTo apply the changes:\033[0m"
  echo -e "- Close and reopen your terminal. (This starts a new session.)"
  echo -e "- Alternatively, run 'exec zsh'. (This reloads the shell in the current terminal.)"
  echo "Setup complete."
}

# Main Script Execution
ensure_local_bin
install_utilities
change_default_shell_to_zsh
apply_dotfiles
setup_tmux_plugin_manager
setup_secrets
configure_locale
install_wt_settings
configure_wsl_terminal_profile
print_completion_message
