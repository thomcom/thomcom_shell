#!/bin/zsh
##############################################################################
# Core ZSH Options - Basic shell behavior
##############################################################################

# Essential options for all shells
setopt autocd              # Change directory by typing directory name
setopt extendedglob        # Extended globbing for advanced pattern matching
setopt interactivecomments # Allow comments in interactive shell
setopt ignoreeof          # Don't exit on Ctrl-D

# Vi mode (universal)
set -o vi

# Correction (command names only, not arguments — CORRECT_ALL causes rendering noise)
setopt CORRECT

# Disable annoying beep
unsetopt beep