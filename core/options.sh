#!/bin/bash
##############################################################################
# Core Bash Options - Basic shell behavior
##############################################################################

# Essential options for all shells
shopt -s autocd              # Change directory by typing directory name
# extendedglob removed - bash extglob less useful, skip for now
# interactivecomments enabled by default in bash
set -o ignoreeof            # Don't exit on Ctrl-D

# Vi mode (universal)
set -o vi

# CORRECT_ALL removed - this is the annoying y/n prompt
# beep handling removed - low priority for initial conversion
