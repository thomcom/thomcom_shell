#!/bin/zsh
##############################################################################
# Modular ZSH Configuration - Main Entry Point
# A beautifully organized shell configuration system
##############################################################################

# Configuration root
export THOMCOM_SHELL_ROOT="${0:A:h}"

# Source a module if it exists
source_module() {
    [[ -f "$THOMCOM_SHELL_ROOT/$1" ]] && source "$THOMCOM_SHELL_ROOT/$1"
}

##############################################################################
# CORE - Always loaded (all shell types, including CLAUDECODE)
##############################################################################
source_module "core/environment.zsh"
source_module "core/options.zsh"
source_module "core/history.zsh"

##############################################################################
# TOOLS - Always loaded for functionality
##############################################################################
source_module "tools/nvm.zsh"
source_module "tools/conda.zsh"
source_module "tools/fzf.zsh"
source_module "tools/system.zsh"

##############################################################################
# FEATURES - Broadcast system and other features
##############################################################################
source_module "features/broadcast.zsh"

##############################################################################
# WORK-SPECIFIC - Load if available and not in CLAUDECODE
##############################################################################
[[ "$CLAUDECODE" != "1" && -f ~/.nvidia/work.zsh ]] && source ~/.nvidia/work.zsh

##############################################################################
# TERMINAL SESSION LOGGING - Only for interactive non-CLAUDECODE shells
##############################################################################
if [[ -o interactive && "$CLAUDECODE" != "1" && -z "$INSIDE_SCRIPT" ]]; then
    # This will exec script and replace current process - must be last!
    source_module "logging/session-tracker.zsh"
fi

##############################################################################
# INTERACTIVE FEATURES - Only after logging setup (inside script session)
##############################################################################
if [[ -o interactive && -n "$INSIDE_SCRIPT" ]]; then
    source_module "interactive/colors.zsh"
    source_module "interactive/prompt.zsh" 
    source_module "interactive/aliases.zsh"
    source_module "interactive/completion.zsh"
    source_module "logging/replay-tools.zsh"
    
    # Work-specific startup (if available)
    command -v _nvidia_startup >/dev/null && _nvidia_startup
    
    echo "🚀 Thomcom Shell loaded successfully"
fi

# Clean up
unset -f source_module