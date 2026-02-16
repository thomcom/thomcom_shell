#!/bin/bash

########
# Modular Bash Configuration - Main Entry Point
# A beautifully organized shell configuration system
########

# Debug launcher - set to 1 to see loading progress
DEBUG_LAUNCHER=${DEBUG_LAUNCHER:-0}

# Configuration root - resolve through symlinks to actual directory
export THOMCOM_SHELL_ROOT="$HOME/.thomcom_shell"

# Load version
if [[ -f "$THOMCOM_SHELL_ROOT/VERSION" ]]; then
    export THOMCOM_SHELL_VERSION="$(< "$THOMCOM_SHELL_ROOT/VERSION")"
    THOMCOM_SHELL_VERSION="${THOMCOM_SHELL_VERSION%$'\n'}"
fi

# Load tier (defaults to full)
if [[ -f "$THOMCOM_SHELL_ROOT/.tier" ]]; then
    THOMCOM_TIER="$(< "$THOMCOM_SHELL_ROOT/.tier")"
    THOMCOM_TIER="${THOMCOM_TIER%$'\n'}"
else
    THOMCOM_TIER="full"
fi
export THOMCOM_TIER

# Source a module if it exists
source_module() {
    [[ -f "$THOMCOM_SHELL_ROOT/$1" ]] && source "$THOMCOM_SHELL_ROOT/$1"
}

# Tier check helpers
tier_at_least_shell() { [[ "$THOMCOM_TIER" == "shell" || "$THOMCOM_TIER" == "full" ]]; }
tier_at_least_full() { [[ "$THOMCOM_TIER" == "full" ]]; }

########
# CORE - Always loaded (all tiers, all shell types)
########
[[ $DEBUG_LAUNCHER -eq 1 ]] && echo "🐚 Loading core modules... TIER=$THOMCOM_TIER CLAUDECODE=$CLAUDECODE INSIDE_SCRIPT=$INSIDE_SCRIPT"
source_module "core/environment.sh"
source_module "core/options.sh"
source_module "core/history.sh"

########
# TOOLS - Tier-dependent loading
########
# base tier: fzf, conda
source_module "tools/conda.sh"

# shell tier: atuin, nvm
if tier_at_least_shell; then
    source_module "tools/atuin.sh"
    source_module "tools/nvm.sh"
fi

# full tier: system (X11 input config)
if tier_at_least_full; then
    source_module "tools/system.sh"
fi

########
# FEATURES - full tier only
########
if tier_at_least_full; then
    source_module "features/broadcast.sh"
fi

########
# WORK-SPECIFIC - Load if available (shell tier and above)
########
if tier_at_least_shell; then
    [[ -f "$THOMCOM_SECRETS_DIR/work.sh" ]] && source "$THOMCOM_SECRETS_DIR/work.sh"
fi

########
# TERMINAL SESSION LOGGING - full tier, interactive non-CLAUDECODE shells only
########
[[ $DEBUG_LAUNCHER -eq 1 ]] && echo "🔍 Logging check: interactive=$([[ $- == *i* ]] && echo "YES" || echo "NO") CLAUDECODE=$CLAUDECODE INSIDE_SCRIPT=$INSIDE_SCRIPT"
if tier_at_least_full && [[ $- == *i* && "$CLAUDECODE" != "1" && -z "$INSIDE_SCRIPT" ]]; then
    [[ $DEBUG_LAUNCHER -eq 1 ]] && echo "📝 Starting session logging - about to exec script!"
    source_module "logging/session-tracker.sh"
else
    [[ $DEBUG_LAUNCHER -eq 1 ]] && echo "⏭️  Skipping session logging"
fi

########
# INTERACTIVE FEATURES - Load for all interactive shells
########
[[ $DEBUG_LAUNCHER -eq 1 ]] && echo "🎨 Interactive check: interactive=$([[ $- == *i* ]] && echo "YES" || echo "NO") INSIDE_SCRIPT=$INSIDE_SCRIPT"
if [[ $- == *i* ]]; then
    [[ $DEBUG_LAUNCHER -eq 1 ]] && echo "🎨 Loading interactive features..."
    source_module "interactive/colors.sh"
    source_module "interactive/prompt.sh"

    # base tier: aliases-base only; shell+full: full aliases (which sources base)
    if tier_at_least_shell; then
        source_module "interactive/aliases.sh"
    else
        source_module "interactive/aliases-base.sh"
    fi

    source_module "interactive/completion.sh"

    if tier_at_least_full; then
        source_module "logging/replay-tools.sh"
    fi

    # Work-specific startup (if available)
    command -v _work_startup >/dev/null && _work_startup

    # Show welcome tutorial on first launch
    if [[ ! -f ~/.thomcom_shell/.welcomed ]]; then
        cat ~/.thomcom_shell/interactive/1st_launch.md 2>/dev/null || echo "🚀 thomcom Shell loaded successfully"
        touch ~/.thomcom_shell/.welcomed
    else
        echo "🚀 thomcom Shell loaded successfully"
    fi
else
    [[ $DEBUG_LAUNCHER -eq 1 ]] && echo "😐 No interactive features loaded (plain shell mode)"
fi

########
# FZF - Load last to prevent keybinding conflicts with other tools (all tiers)
########
source_module "tools/fzf.sh"

# Clean up
unset -f source_module tier_at_least_shell tier_at_least_full

export TERM=xterm-256color
export TERMINFO=/usr/share/terminfo

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
. "$HOME/.cargo/env"

# Google Cloud SDK
export PATH="$HOME/google-cloud-sdk/bin:$PATH"
if [ -f "$HOME/google-cloud-sdk/path.bash.inc" ]; then . "$HOME/google-cloud-sdk/path.bash.inc"; fi
if [ -f "$HOME/google-cloud-sdk/completion.bash.inc" ]; then . "$HOME/google-cloud-sdk/completion.bash.inc"; fi
