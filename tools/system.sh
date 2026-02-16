#!/bin/bash
##############################################################################
# System Configuration - Display and power management
##############################################################################

# Only apply system tweaks in interactive shells
[[ $- != *i* ]] && return

# Disable screen saver and power management
xset s off -dpms || true

# Remap Caps Lock to Escape
setxkbmap -option caps:escape || true

# Configure touchpad - Enable tapping and two-finger right-click
# Find the Synaptics touchpad device and configure it
TOUCHPAD_ID=$(xinput list | grep -i "Synaptics TM3276-022" | grep -oP 'id=\K\d+')
if [[ -n "$TOUCHPAD_ID" ]]; then
    # Enable tap-to-click
    xinput set-prop "$TOUCHPAD_ID" "libinput Tapping Enabled" 1 || true
    # Enable clickfinger method (two-finger tap = right click, three-finger tap = middle click)
    xinput set-prop "$TOUCHPAD_ID" "libinput Click Method Enabled" 0 1 || true
fi
