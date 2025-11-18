#!/bin/bash
# Keyboard Remapping Installation Script for thomcom_shell
# Installs xremap and sets up keyboard remapping configuration

set -e

echo "========================================="
echo "Keyboard Remapping Installation"
echo "========================================="
echo ""

# Check if Rust is installed
if ! command -v cargo &> /dev/null; then
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
else
    echo "✓ Rust is already installed"
fi

# Install xremap if not already installed
if ! command -v xremap &> /dev/null; then
    echo "Installing xremap with X11 support..."
    cargo install xremap --features x11
else
    echo "✓ xremap is already installed"
fi

# Create config directory
echo "Setting up xremap configuration..."
mkdir -p ~/.config/xremap

# Symlink or copy config
if [ -f ~/.thomcom_shell/keyboard_remapping/config.yml ]; then
    ln -sf ~/.thomcom_shell/keyboard_remapping/config.yml ~/.config/xremap/config.yml
    echo "✓ Configuration linked to ~/.config/xremap/config.yml"
else
    echo "ERROR: config.yml not found in ~/.thomcom_shell/keyboard_remapping/"
    exit 1
fi

# Check if i3 config exists and add xremap startup if not already present
if [ -f ~/.config/i3/config ]; then
    if ! grep -q "xremap" ~/.config/i3/config; then
        echo ""
        echo "Adding xremap to i3 startup..."
        echo "" >> ~/.config/i3/config
        echo "# xremap - Keyboard remapping at evdev level (Caps->Esc, Esc->Grave, Super+hjkl->arrows)" >> ~/.config/i3/config
        echo "# Runs with sudo, device-independent (works with any keyboard)" >> ~/.config/i3/config
        echo "exec --no-startup-id sudo -E \$HOME/.cargo/bin/xremap \$HOME/.config/xremap/config.yml --watch" >> ~/.config/i3/config
        echo "✓ Added xremap to i3 config"
        echo "  You'll need to reload i3: Mod+Shift+r"
    else
        echo "✓ xremap already in i3 config"
    fi
else
    echo "⚠ i3 config not found at ~/.config/i3/config"
    echo "  You'll need to manually add xremap to your window manager startup"
fi

echo ""
echo "========================================="
echo "Installation Complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo "1. Reload your window manager (i3: Mod+Shift+r)"
echo "2. Or start xremap manually:"
echo "   sudo -E \$HOME/.cargo/bin/xremap \$HOME/.config/xremap/config.yml --watch &"
echo ""
echo "Test the remapping:"
echo "  - Caps Lock → Escape"
echo "  - Escape → Grave/Tilde (\`)"
echo "  - Super+h/j/k/l → Arrow keys"
echo ""
