#!/bin/zsh
##############################################################################
#  📡 ZSH Broadcast System - Execute commands in all active zsh sessions
##############################################################################

# Skip broadcast setup for Claude Code agents
[[ "$CLAUDECODE" == "1" ]] && return

# Create broadcast directory
mkdir -p ~/.zsh_broadcasts

# Track processed broadcasts to avoid re-execution
export ZSH_BROADCAST_STATE=~/.zsh_broadcast_state_$$

# Initialize state file with current broadcasts (avoid executing old ones on startup)
if [[ ! -f "$ZSH_BROADCAST_STATE" ]]; then
  # Mark all existing broadcasts as processed
  for broadcast in ~/.zsh_broadcasts/broadcast_*; do
    [[ -f "$broadcast" ]] && echo "$(basename "$broadcast")" >> "$ZSH_BROADCAST_STATE"
  done
fi

# Process new broadcasts
_check_broadcasts() {
  local broadcast_file
  local broadcast_cmd
  local broadcast_name
  
  for broadcast_file in ~/.zsh_broadcasts/broadcast_*; do
    [[ -f "$broadcast_file" ]] || continue
    
    broadcast_name=$(basename "$broadcast_file")
    
    # Skip if we've already processed this broadcast
    if grep -q "^$broadcast_name$" "$ZSH_BROADCAST_STATE" 2>/dev/null; then
      continue
    fi
    
    # Skip broadcasts from our own PID (avoid executing our own commands)
    if [[ "$broadcast_name" == *"_$$_"* ]]; then
      echo "$broadcast_name" >> "$ZSH_BROADCAST_STATE"
      continue
    fi
    
    # Read and execute the command
    if broadcast_cmd=$(cat "$broadcast_file" 2>/dev/null); then
      echo "📡 Executing broadcast: $broadcast_cmd"
      
      # Execute in a subshell to isolate errors
      (eval "$broadcast_cmd") 2>/dev/null || echo "📡 Broadcast execution failed: $broadcast_cmd"
      
      # Mark as processed
      echo "$broadcast_name" >> "$ZSH_BROADCAST_STATE"
    fi
  done
}

# Signal handler for broadcasts
TRAPUSR1() {
  _check_broadcasts
}

# Hook into existing precmd for periodic checking
_broadcast_precmd() {
  # Check for broadcasts periodically (every 10 commands to avoid overhead)
  (( ${#history[@]} % 10 == 0 )) && _check_broadcasts
}

# Add our check to precmd - handle if precmd already exists
if (( ${+functions[precmd]} )); then
  # Rename existing precmd
  functions[_orig_precmd]=${functions[precmd]}
  precmd() {
    _orig_precmd "$@"
    _broadcast_precmd
  }
else
  # No existing precmd, create one
  precmd() {
    _broadcast_precmd
  }
fi

# Broadcast command function
zbc() {
  local cmd="$*"
  [[ -z "$cmd" ]] && { echo "Usage: zbc <command>"; return 1; }
  
  # Create broadcast file
  local broadcast_file=~/.zsh_broadcasts/broadcast_$$_$(date +%s)_$RANDOM
  echo "$cmd" > "$broadcast_file" || { echo "Failed to create broadcast"; return 1; }
  
  echo "📡 Broadcasting: $cmd"
  
  # Signal all zsh processes except ourselves
  pkill -USR1 -f "zsh" 2>/dev/null || true
  
  return 0
}

# Cleanup function for broadcast state
_cleanup_broadcast_state() {
  [[ -f "$ZSH_BROADCAST_STATE" ]] && rm -f "$ZSH_BROADCAST_STATE"
}

# Add cleanup to existing TRAPEXIT if it exists
if (( ${+functions[TRAPEXIT]} )); then
  functions[_orig_trapexit]=${functions[TRAPEXIT]}
  TRAPEXIT() {
    _orig_trapexit "$@"
    _cleanup_broadcast_state
  }
else
  TRAPEXIT() {
    _cleanup_broadcast_state
  }
fi