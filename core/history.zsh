#!/bin/zsh
##############################################################################
# History Configuration - Session-scoped history with shared file batching
##############################################################################

# Skip complex history setup for Claude Code agents - use simple version
if [[ "$CLAUDECODE" == "1" ]]; then
    export HISTFILE=~/.zsh_history
    export HISTSIZE=1000
    export SAVEHIST=1000
    setopt SHARE_HISTORY
    return
fi

##############################################################################
# Session-scoped history, batched to a shared file
##############################################################################
export SHARED_HISTFILE=$HOME/.zsh_history
export SESSION_HISTFILE=${TMPDIR:-/tmp}/zsh_hist_${$}_${RANDOM}
HISTFILE=$SESSION_HISTFILE
HISTSIZE=1000000000000
SAVEHIST=$HISTSIZE

# Load the shared history ONCE
if [[ -r $SHARED_HISTFILE ]]; then
  fc -R -- $SHARED_HISTFILE          # import
  _flushed_cnt=${#history[@]}        # mark baseline so we don't re-write it
fi

# Flush only commands added *after* the baseline
integer FLUSH_EVERY=10
_hist_flush() {
  fc -AI -- $SHARED_HISTFILE 2>/dev/null || fc -A -- $SHARED_HISTFILE 2>/dev/null
  _flushed_cnt=${#history[@]}
}

# Essential history options
setopt APPEND_HISTORY          # Append rather than overwrite
setopt INC_APPEND_HISTORY      # Write immediately, don't wait for exit
setopt HIST_IGNORE_DUPS        # Ignore consecutive duplicates

precmd()  { (( ${#history[@]} - _flushed_cnt >= FLUSH_EVERY )) && _hist_flush }
periodic() { (( ${#history[@]} > 0)) && _hist_flush }

# Fix TRAPEXIT syntax and ensure history is written on exit
TRAPEXIT() { 
  _hist_flush
  # Clean up session temp file
  [[ -f "$SESSION_HISTFILE" ]] && rm -f "$SESSION_HISTFILE"
}