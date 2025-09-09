#!/bin/zsh
##############################################################################
# System Configuration - Display and power management
##############################################################################

# Only apply system tweaks in interactive shells
[[ ! -o interactive ]] && return

# Disable screen saver and power management
xset s off -dpms 2>/dev/null || true