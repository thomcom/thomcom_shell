#!/bin/bash
##############################################################################
# Kitty Terminal Configuration
# Sets up kitty terminal emulator with vim-style scrollback navigation
##############################################################################

# Install kitty config if not present
_setup_kitty_config() {
    local kitty_config_dir="$HOME/.config/kitty"
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local thomcom_kitty_conf="$script_dir/kitty/kitty.conf"

    # Only proceed if kitty is installed
    if ! command -v kitty >/dev/null 2>&1; then
        return 0
    fi

    # Create config directory if needed
    if [[ ! -d "$kitty_config_dir" ]]; then
        mkdir -p "$kitty_config_dir"
    fi

    # Symlink config if not present or if it's already our symlink
    if [[ ! -f "$kitty_config_dir/kitty.conf" ]]; then
        ln -s "$thomcom_kitty_conf" "$kitty_config_dir/kitty.conf"
    elif [[ -L "$kitty_config_dir/kitty.conf" ]]; then
        # Update symlink if it points elsewhere
        local current_target=$(readlink "$kitty_config_dir/kitty.conf")
        if [[ "$current_target" != "$thomcom_kitty_conf" ]]; then
            ln -sf "$thomcom_kitty_conf" "$kitty_config_dir/kitty.conf"
        fi
    fi
}

# Run setup on shell init
_setup_kitty_config
