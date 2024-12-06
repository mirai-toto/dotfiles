#!/bin/bash

# Determine the directory of the script
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Homebrew
echo "Installing Homebrew..."
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "Homebrew is already installed."
fi

# Ensure Homebrew environment variables are set
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Add Homebrew to ~/.profile for future sessions
if ! grep -q 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' ~/.profile; then
  echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.profile
  echo "Added Homebrew initialization to ~/.profile."
else
  echo "Homebrew initialization already present in ~/.profile."
fi

brew analytics off

# Utilities
echo "Installing utilities..."
brew install zsh tldr fzf bat fd zoxide lua luajit luarocks prettier ripgrep yazi stow eza lazygit tmux neovim

# Change default shell to Homebrew's Zsh
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

# Clone TPM if not present
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  echo "Cloning TPM..."
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
else
  echo "TPM is already installed."
fi

# Check and create $HOME/.local/bin if it doesn't exist
if [ ! -d "$HOME/.local/bin" ]; then
  echo "Creating $HOME/.local/bin directory..."
  mkdir -p "$HOME/.local/bin"
fi

# Navigate to dotfiles directory
if [ -d "$SCRIPT_DIR/tmux" ] && [ -d "$SCRIPT_DIR/shell" ]; then
  cd "$SCRIPT_DIR" || exit
  echo "Stowing tmux and shell..."
  stow -t ~ tmux shell
elif [ ! -d "$SCRIPT_DIR/tmux" ]; then
  echo "Directory $SCRIPT_DIR/tmux not found. Skipping tmux setup."
  exit 1
elif [ ! -d "$SCRIPT_DIR/shell" ]; then
  echo "Directory $SCRIPT_DIR/shell not found. Skipping shell setup."
  exit 1
fi

# Stow scripts
if [ -d "$SCRIPT_DIR/scripts" ]; then
  echo "Stowing scripts..."
  stow -t "$HOME/.local/bin/" scripts
else
  echo "Scripts directory not found in dotfiles."
  exit 1
fi

# Change default shell to Homebrew's Zsh
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

# Install TMUX plugins
if [ -d "$HOME/.tmux/plugins/tpm" ]; then
  echo "Installing TMUX plugins..."
  "$HOME/.tmux/plugins/tpm/bin/install_plugins"
  echo "TMUX plugins installed successfully."
else
  echo "TPM is not installed. Skipping plugin installation."
fi

# Ensure en_US.UTF-8 locale is generated
echo "Configuring locale..."
if ! locale -a | grep -q "en_US.utf8"; then
  sudo locale-gen en_US.UTF-8
  sudo update-locale LANG=en_US.UTF-8
  echo "Locale en_US.UTF-8 configured successfully."
else
  echo "Locale en_US.UTF-8 is already configured."
fi

# Add message to restart terminal
echo -e "\033[31mTo apply the changes:\033[0m"
echo -e "- Close and reopen your terminal. (This starts a new session.)"
echo -e "- Alternatively, run 'exec zsh'. (This reloads the shell in the current terminal.)"

echo "Setup complete."

