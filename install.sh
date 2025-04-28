#!/bin/bash

set -e

# Check if Nim is installed
if ! command -v nim &> /dev/null; then
    echo "Nim is not installed. Please install it from https://nim-lang.org/"
    exit 1
fi

# Build the project
echo "Building jv..."
nim c -d:release -o:bin/jv src/main.nim

# Set up installation directories
INSTALL_DIR="$HOME/.jv"
BIN_DIR="$HOME/.local/bin"

# Create directories
mkdir -p "$INSTALL_DIR/bin"
mkdir -p "$BIN_DIR"

# Copy binary
cp bin/jv "$INSTALL_DIR/bin/"
chmod +x "$INSTALL_DIR/bin/jv"

# Create symlink
ln -sf "$INSTALL_DIR/bin/jv" "$BIN_DIR/jv"

# Add to PATH if not already there
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    if [ -f ~/.zshrc ]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
    fi
fi

echo "jv has been installed successfully!"
echo "Please restart your terminal to use jv."