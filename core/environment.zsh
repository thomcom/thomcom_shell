#!/bin/zsh
##############################################################################
# Core Environment - Essential exports and paths
# Loaded by all shells (interactive, non-interactive, CLAUDECODE)
##############################################################################

# Essential PATH components
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:/usr/local/cuda/bin"
export PATH="$PATH:$HOME/bin/s3cmd-2.3.0"
export PATH="$PATH:$HOME/bin"
export PATH="$PATH:$HOME/.local/bin"

# Core environment variables (work-specific vars loaded separately)

# Build tools
export GRADLE_HOME=/opt/gradle/gradle-8.8
export ADB_PATH=$HOME/Android/Sdk/platform-tools
export PATH="$PATH:$GRADLE_HOME/bin:$ADB_PATH"

# Development tools
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# Python/Pip configuration
export PIP_CACHE_DIR=$HOME/data/pip_cache
export PYTHONPATH=$PWD

# Additional tools (work-specific tools loaded separately)

# Manual/pager configuration
export MANPAGER="vim -c 'Man!' -o -"

# Private keys (if available)
[[ -f ~/.nvidia/keys.sh ]] && source ~/.nvidia/keys.sh