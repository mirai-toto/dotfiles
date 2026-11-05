#!/bin/bash
# Install the packages listed in CargoPackages, one crate per line.

SCRIPT_DIR=$(dirname "$(realpath "$0")")
export PATH="$(brew --prefix rustup)/bin:$HOME/.cargo/bin:$PATH"

if ! command -v cargo >/dev/null 2>&1; then
  echo "Cargo is required to install packages in CargoPackages. Install rustup first." >&2
  exit 1
fi

if ! cargo --version >/dev/null 2>&1; then
  echo "Installing the stable Rust toolchain..."
  "$(brew --prefix rustup)/bin/rustup" default stable || exit 1
fi

while IFS= read -r package || [ -n "$package" ]; do
  case "$package" in
  '' | \#*) continue ;;
  esac
  cargo install --locked "$package" || exit 1
done <"$SCRIPT_DIR/CargoPackages"
