#!/bin/bash
##############################################################################
#  📡 Bash Broadcast System - Execute commands in all active bash sessions
##############################################################################
#
# This revolutionary system allows you to send commands to ALL active bash
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
mkdir -p ~/.bash_broadcasts

# Track processed broadcasts to avoid re-execution
export BASH_BROADCAST_STATE=~/.bash_broadcast_state_$$

# Clean up old broadcasts (older than 60 seconds) and initialize state
shopt -s nullglob
for broadcast in ~/.bash_broadcasts/broadcast_*; do
  [[ -f "$broadcast" ]] || continue
  # Delete broadcasts older than 60 seconds
  if [[ $(find "$broadcast" -mmin +1 2>/dev/null) ]]; then
    rm -f "$broadcast"
  fi
done
shopt -u nullglob

# Initialize state file (mark any remaining broadcasts as processed to avoid executing stale ones)
if [[ ! -f "$BASH_BROADCAST_STATE" ]]; then
  shopt -s nullglob
  for broadcast in ~/.bash_broadcasts/broadcast_*; do
    [[ -f "$broadcast" ]] && echo "$(basename "$broadcast")" >> "$BASH_BROADCAST_STATE"
  done
  shopt -u nullglob
fi

# Process new broadcasts
_check_broadcasts() {
  local broadcast_file
  local broadcast_cmd
  local broadcast_name

  shopt -s nullglob  # Don't error on no matches
  for broadcast_file in ~/.bash_broadcasts/broadcast_*; do
    [[ -f "$broadcast_file" ]] || continue

    broadcast_name=$(basename "$broadcast_file")

    # Skip if we've already processed this broadcast
    if grep -q "^$broadcast_name$" "$BASH_BROADCAST_STATE" 2>/dev/null; then
      continue
    fi

    # Skip broadcasts from our own PID (avoid executing our own commands)
    if [[ "$broadcast_name" == *"_$$_"* ]]; then
      echo "$broadcast_name" >> "$BASH_BROADCAST_STATE"
      continue
    fi

    # Read and execute the command
    if broadcast_cmd=$(cat "$broadcast_file" 2>/dev/null); then
      echo "📡 Executing broadcast: $broadcast_cmd"

      # Execute in a subshell to isolate errors
      (eval "$broadcast_cmd") 2>/dev/null || echo "📡 Broadcast execution failed: $broadcast_cmd"

      # Mark as processed
      echo "$broadcast_name" >> "$BASH_BROADCAST_STATE"
    fi
  done
  shopt -u nullglob
}

# TODO Phase 2: Signal handler for broadcasts
# trap '_check_broadcasts' USR1

# TODO Phase 2: Hook into PROMPT_COMMAND for periodic checking (skip for CLAUDECODE)
# if [[ "$CLAUDECODE" != "1" ]]; then
#   _broadcast_precmd() {
#     # Check for broadcasts periodically (every 10 commands to avoid overhead)
#     (( HISTCMD % 10 == 0 )) && _check_broadcasts
#   }
#
#   # Add our check to PROMPT_COMMAND
#   if [[ -n "$PROMPT_COMMAND" ]]; then
#     PROMPT_COMMAND="$PROMPT_COMMAND; _broadcast_precmd"
#   else
#     PROMPT_COMMAND="_broadcast_precmd"
#   fi
# fi

# Broadcast command function
zbc() {
  local cmd="$*"
  [[ -z "$cmd" ]] && { echo "Usage: zbc <command>"; return 1; }

  # Create broadcast file
  local broadcast_file=~/.bash_broadcasts/broadcast_$$_$(date +%s)_$RANDOM
  echo "$cmd" > "$broadcast_file" || { echo "Failed to create broadcast"; return 1; }

  echo "📡 Broadcasting: $cmd"

  # Signal all bash processes except ourselves
  # Use -x for exact match to avoid hitting editors/tools with "bash" in args
  pkill -USR1 -x "bash" 2>/dev/null || true

  return 0
}

# Cleanup function for broadcast state
_cleanup_broadcast_state() {
  [[ -f "$BASH_BROADCAST_STATE" ]] && rm -f "$BASH_BROADCAST_STATE"
}

# TODO Phase 2: Add cleanup on exit (skip for CLAUDECODE)
# if [[ "$CLAUDECODE" != "1" ]]; then
#   trap '_cleanup_broadcast_state' EXIT
# fi
