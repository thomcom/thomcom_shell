#!/bin/zsh

########
# Modular ZSH Configuration - Main Entry Point
# A beautifully organized shell configuration system
########

# Debug launcher - set to 1 to see loading progress
DEBUG_LAUNCHER=${DEBUG_LAUNCHER:-0}

# Configuration root - resolve through symlinks to actual directory
export THOMCOM_SHELL_ROOT="$HOME/.thomcom_shell"

# Source a module if it exists
source_module() {
    [[ -f "$THOMCOM_SHELL_ROOT/$1" ]] && source "$THOMCOM_SHELL_ROOT/$1"
}

########
# CORE - Always loaded (all shell types, including CLAUDECODE)
########
[[ $DEBUG_LAUNCHER -eq 1 ]] && echo "🐚 Loading core modules... CLAUDECODE=$CLAUDECODE INSIDE_SCRIPT=$INSIDE_SCRIPT"
source_module "core/environment.zsh"
source_module "core/options.zsh"
source_module "core/history.zsh"

########
# TOOLS - Always loaded for functionality (fzf last to prevent keybinding conflicts)
########
source_module "tools/nvm.zsh"
source_module "tools/conda.zsh" 
source_module "tools/system.zsh"

########
# FEATURES - Broadcast system and other features
########
source_module "features/broadcast.zsh"

########
# WORK-SPECIFIC - Load if available (includes CLAUDECODE for full environment access)
########
[[ -f "$THOMCOM_SECRETS_DIR/work.zsh" ]] && source "$THOMCOM_SECRETS_DIR/work.zsh"

########
# TERMINAL SESSION LOGGING - Only for interactive non-CLAUDECODE shells
########
[[ $DEBUG_LAUNCHER -eq 1 ]] && echo "🔍 Logging check: interactive=$([[ -o interactive ]] && echo "YES" || echo "NO") CLAUDECODE=$CLAUDECODE INSIDE_SCRIPT=$INSIDE_SCRIPT"
if [[ -o interactive && "$CLAUDECODE" != "1" && -z "$INSIDE_SCRIPT" ]]; then
    [[ $DEBUG_LAUNCHER -eq 1 ]] && echo "📝 Starting session logging - about to exec script!"
    # This will exec script and replace current process - must be last!
    source_module "logging/session-tracker.zsh"
else
    [[ $DEBUG_LAUNCHER -eq 1 ]] && echo "⏭️  Skipping session logging"
fi

########
# INTERACTIVE FEATURES - Only after logging setup (inside script session)
########
[[ $DEBUG_LAUNCHER -eq 1 ]] && echo "🎨 Interactive check: interactive=$([[ -o interactive ]] && echo "YES" || echo "NO") INSIDE_SCRIPT=$INSIDE_SCRIPT"
if [[ -o interactive && -n "$INSIDE_SCRIPT" ]]; then
    [[ $DEBUG_LAUNCHER -eq 1 ]] && echo "🎨 Loading interactive features..."
    source_module "interactive/colors.zsh"
    source_module "interactive/prompt.zsh" 
    source_module "interactive/aliases.zsh"
    source_module "interactive/completion.zsh"
    source_module "logging/replay-tools.zsh"
    
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
# FZF - Load last to prevent keybinding conflicts with other tools
########
source_module "tools/fzf.zsh"

# Clean up
unset -f source_module
