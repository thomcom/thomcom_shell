# Keyboard Remapping for thomcom_shell

## Quick Start
On a new system installation:
```bash
cd ~/.thomcom_shell/keyboard_remapping
./install.sh
```

## What This Does
Sets up universal keyboard remapping that works with **any keyboard** (USB hotswap compatible):
- **Caps Lock → Escape**
- **Escape → Grave/Tilde (`)**
- **Super+h/j/k/l → Arrow keys**

## Directory Structure
```
~/.thomcom_shell/
└── keyboard_remapping/
    ├── README.md       # Detailed documentation
    ├── install.sh      # Automated installation script
    └── config.yml      # xremap configuration file
```

## Why This Solution?
After extensive troubleshooting (6-8 hours), we determined that **xremap** is the only reliable solution because it operates at the **Linux kernel evdev level**, intercepting keys before they reach:
- X11/Xorg
- Window managers (i3, etc.)
- Applications

This makes it:
- ✅ Universal across all applications
- ✅ Works with any keyboard (device-independent)
- ✅ Survives keyboard hotswap
- ✅ Persistent across reboots

## Files Outside This Directory

### Active Configuration
- `~/.config/xremap/config.yml` - Active xremap config (symlinked from thomcom_shell)
- `~/.config/i3/config` - Contains xremap startup command

### Documentation
- `~/.config/KEYBOARD_REMAPPING_SOLUTION.md` - Complete troubleshooting history and technical deep-dive

### Archived (Old Solutions That Failed)
- `~/.config/old_keyboard_configs/` - Archived xmodmap and xbindkeys configs
- `~/.config/autostart/xmodmap.desktop` - Disabled
- `~/.config/autostart/setxkbmap.desktop` - Disabled

## Requirements
- Rust/Cargo (installed automatically by install.sh)
- sudo access (xremap needs to access /dev/input devices)
- X11 or Wayland

## Tested On
- Ubuntu 24.04
- i3 window manager
- Multiple USB keyboards (SEMICO Gaming Keyboard, others)

## Maintenance
To modify key mappings, edit:
```bash
~/.thomcom_shell/keyboard_remapping/config.yml
```

Then reload:
```bash
sudo pkill -9 xremap
sudo -E $HOME/.cargo/bin/xremap $HOME/.config/xremap/config.yml --watch &
```

Or just restart i3: `Mod+Shift+r`

## References
- xremap GitHub: https://github.com/xremap/xremap
- Detailed solution blog: https://www.paolomainardi.com/posts/linux-remapping-keys-with-xremap/
