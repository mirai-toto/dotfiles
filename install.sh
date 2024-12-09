#!/bin/bash

# Homebrew
echo "Installing Homebrew..."
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "Homebrew is already installed."
fi
brew analytics off

# Utilities
echo "Installing utilities..."
brew install zsh tldr fzf bat fd zoxide lua luajit luarocks prettier ripgrep yazi

# Terminal tools
echo "Installing terminal tools..."
brew install lazygit tmux neovim

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
if [ -d "$HOME/dotfiles" ]; then
  cd "$HOME/dotfiles" || exit
  echo "Stowing dotfiles..."
  stow -t ~ tmux shell
else
  echo "Directory $HOME/dotfiles not found. Skipping dotfiles setup."
fi

# Stow scripts
if [ -d "$HOME/dotfiles/scripts" ]; then
  echo "Stowing scripts..."
  stow -t "$HOME/.local/bin/" scripts
else
  echo "Scripts directory not found in dotfiles."
fi

echo "Setup complete."

