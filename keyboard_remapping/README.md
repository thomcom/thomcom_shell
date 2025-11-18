# Keyboard Remapping Setup for thomcom_shell

## Overview
This directory contains the configuration and installation scripts for keyboard remapping using **xremap**, an evdev-level keyboard remapper that works universally across all keyboards and applications.

## What Gets Remapped
1. **Caps Lock → Escape** (universal Escape key)
2. **Physical Escape key → Grave/Tilde (`)** (convenient backtick access)
3. **Super+h → Left Arrow**
4. **Super+j → Down Arrow**
5. **Super+k → Up Arrow**
6. **Super+l → Right Arrow**

Note: Alt+hjkl remains free for i3 window manager focus commands.

## Why xremap?
After extensive troubleshooting (6-8 hours), we determined that:
- **xmodmap**: Only works at X11 level, not persistent across keyboard changes
- **setxkbmap**: Limited remapping capabilities, conflicts with other tools
- **xbindkeys**: Operates at X client level (lowest priority), cannot intercept keys before window managers

**xremap** operates at the **evdev level** (kernel input layer), making it:
- Universal across all applications
- Device-independent (works with any keyboard)
- Persistent across keyboard hotswaps
- Higher priority than window managers

## Files in This Directory
- `README.md` - This file
- `install.sh` - Installation script for new systems
- `config.yml` - xremap configuration (symlinked to ~/.config/xremap/config.yml)

## Installation on New System

### Quick Install
```bash
cd ~/.thomcom_shell/keyboard_remapping
./install.sh
```

### Manual Installation Steps
1. Install Rust (if not already installed):
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
   source "$HOME/.cargo/env"
   ```

2. Install xremap:
   ```bash
   cargo install xremap --features x11
   ```

3. Set up configuration:
   ```bash
   mkdir -p ~/.config/xremap
   ln -sf ~/.thomcom_shell/keyboard_remapping/config.yml ~/.config/xremap/config.yml
   ```

4. Add to i3 config (or your window manager startup):
   ```bash
   # Add this line to ~/.config/i3/config
   exec --no-startup-id sudo -E $HOME/.cargo/bin/xremap $HOME/.config/xremap/config.yml --watch
   ```

5. Reload i3 or restart your session

## Testing
After installation:
- Press **Caps Lock** → Should act as Escape
- Press **Escape** → Should type backtick (`)
- Press **Super+h/j/k/l** → Should move cursor with arrow keys
- Plug in a different USB keyboard → Should work immediately

## Troubleshooting

### xremap not starting
- Check if running: `ps aux | grep xremap`
- Check sudo permissions: `sudo -E $HOME/.cargo/bin/xremap --version`
- Check config syntax: `$HOME/.cargo/bin/xremap $HOME/.config/xremap/config.yml --dry-run`

### Keys not remapping
- Restart xremap: `sudo pkill -9 xremap && sudo -E $HOME/.cargo/bin/xremap $HOME/.config/xremap/config.yml --watch &`
- Check xremap is monitoring your keyboard: Look for your keyboard in the "Selected keyboards" output

### Caps Lock produces backtick instead of Escape
- This was an earlier bug where both remaps were chaining (CapsLock→Esc→Grave)
- Fixed by using separate modmap entries and KEY_ESC for physical Escape key

## Additional Documentation
See `~/.config/KEYBOARD_REMAPPING_SOLUTION.md` for complete troubleshooting history and technical details.

## License
Configuration is part of thomcom_shell personal setup.
xremap is licensed under MIT: https://github.com/xremap/xremap
