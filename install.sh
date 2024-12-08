#!/bin/bash

# Homebrew
echo "Installing Brew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew analytics off

# Utilities
brew install zsh
brew install tldr
brew install fzf
brew install bat
brew install fd
brew install zoxide
brew install lua
brew install luajit
brew install luarocks
brew install prettier
brew install ripgrep
brew install yazi

### Terminal
brew install lazygit
brew install tmux
brew install neovim

# Navigate to dotfiles directory
cd $HOME/dotfiles || exit

# Stow dotfiles packages
stow -t ~ tmux shell scripts
