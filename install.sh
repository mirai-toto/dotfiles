#!/bin/bash

SCRIPT_DIR=$(dirname "$(realpath "$0")")

ensure_local_bin() {
  if [ ! -d "$HOME/.local/bin" ]; then
    echo "Creating $HOME/.local/bin directory..."
    mkdir -p "$HOME/.local/bin"
  fi
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
  brew install zsh tldr fzf bat fd zoxide lua luajit luarocks prettier ripgrep yazi stow eza lazygit tmux neovim xclip tree
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

stow_path() {
  local target_dir=$1
  local dest_dir=$2

  if [ ! -d "$dest_dir" ]; then
    echo "Destination directory $dest_dir does not exist. Creating it..."
    mkdir -p "$dest_dir"
  fi

  if [ -d "$target_dir" ]; then
    echo "Stowing $(basename "$target_dir")..."
    stow -t "$dest_dir" "$target_dir"
  else
    echo "Directory $target_dir not found. Skipping $(basename "$target_dir") setup."
    exit 1
  fi
}

stow_dotfiles() {
  cd "$SCRIPT_DIR" || exit
  stow_path "tmux" "$HOME"
  stow_path "shell" "$HOME"
  stow_path "scripts" "$HOME/.local/bin"
  stow_path "nvim" "$HOME/.config/nvim"
}

setup_tmux_plugin_manager() {
  if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "Cloning TPM..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  else
    echo "TPM is already installed."
  fi
}

install_tmux_plugins() {
  setup_tmux_plugin_manager
  if [ -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "Installing TMUX plugins..."
    "$HOME/.tmux/plugins/tpm/bin/install_plugins"
    echo "TMUX plugins installed successfully."
  else
    echo "TPM is not installed. Skipping plugin installation."
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

configure_wsl_terminal_profile() {
  if [ -z "$WSL_DISTRO_NAME" ]; then
    echo "Not running inside WSL. Skipping Windows Terminal profile configuration."
    return
  fi

  WIN_SCRIPT_PATH=$(wslpath -w "$SCRIPT_DIR/update_terminal_profile.ps1")
  powershell.exe -ExecutionPolicy Bypass -File "$WIN_SCRIPT_PATH" -ProfileName "$WSL_DISTRO_NAME"
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
stow_dotfiles
install_tmux_plugins
configure_locale
configure_wsl_terminal_profile
print_completion_message
