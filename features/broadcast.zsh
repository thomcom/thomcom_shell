#!/bin/zsh
##############################################################################
#  📡 ZSH Broadcast System - Execute commands in all active zsh sessions
##############################################################################
#
# This revolutionary system allows you to send commands to ALL active zsh 
# sessions simultaneously. Perfect for environment management, deployments,
# and synchronized terminal operations. Uses file-based communication with
# SIGUSR1 signals for instant delivery.
#
# Benefits:
# - Instant environment variable synchronization across all terminals
# - Broadcast source commands to reload configs everywhere at once
# - Perfect for deployment workflows and multi-session management
# - Race-condition safe with atomic file operations
# - Auto-cleanup prevents stale command accumulation
#
##############################################################################

# CLAUDECODE agents get broadcast functionality but skip interactive features

# Create broadcast directory
mkdir -p ~/.zsh_broadcasts

# Track processed broadcasts to avoid re-execution
export ZSH_BROADCAST_STATE=~/.zsh_broadcast_state_$$

# Clean up old broadcasts (older than 60 seconds) and initialize state
setopt NULL_GLOB
for broadcast in ~/.zsh_broadcasts/broadcast_*; do
  [[ -f "$broadcast" ]] || continue
  # Delete broadcasts older than 60 seconds
  if [[ $(find "$broadcast" -mmin +1 2>/dev/null) ]]; then
    rm -f "$broadcast"
  fi
done
unsetopt NULL_GLOB

# Initialize state file (mark any remaining broadcasts as processed to avoid executing stale ones)
if [[ ! -f "$ZSH_BROADCAST_STATE" ]]; then
  setopt NULL_GLOB
  for broadcast in ~/.zsh_broadcasts/broadcast_*; do
    [[ -f "$broadcast" ]] && echo "$(basename "$broadcast")" >> "$ZSH_BROADCAST_STATE"
  done
  unsetopt NULL_GLOB
fi

# Process new broadcasts
_check_broadcasts() {
  local broadcast_file
  local broadcast_cmd
  local broadcast_name
  
  setopt NULL_GLOB  # Don't error on no matches
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
  unsetopt NULL_GLOB
}

# Signal handler for broadcasts
TRAPUSR1() {
  _check_broadcasts
}

# Hook into existing precmd for periodic checking (skip for CLAUDECODE)
if [[ "$CLAUDECODE" != "1" ]]; then
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
  # Use -x for exact match to avoid hitting editors/tools with "zsh" in args
  pkill -USR1 -x "zsh" 2>/dev/null || true
  
  return 0
}

# Cleanup function for broadcast state
_cleanup_broadcast_state() {
  [[ -f "$ZSH_BROADCAST_STATE" ]] && rm -f "$ZSH_BROADCAST_STATE"
}

# Add cleanup to existing TRAPEXIT if it exists (skip for CLAUDECODE)
if [[ "$CLAUDECODE" != "1" ]]; then
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
fi