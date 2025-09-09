#!/bin/zsh
##############################################################################
# Terminal Session Logging - Records all terminal sessions using `script`
# Only loaded for interactive shells that are NOT CLAUDECODE
##############################################################################

# Skip if not in a top-level interactive shell or if CLAUDECODE
[[ -n "$INSIDE_SCRIPT" || "$CLAUDECODE" == "1" || ! -o interactive ]] && return

# Only run this block in XFCE environment
[[ "$XDG_CURRENT_DESKTOP" != "XFCE" ]] && return

# Mark that we're about to enter script
export INSIDE_SCRIPT=1

# Detect workspace and session context
if command -v i3-msg >/dev/null && command -v jq >/dev/null; then
    # Full i3 integration - get actual workspace and session info
    export WORKSPACE="$(i3-msg -t get_workspaces 2>/dev/null | jq -r '.[] | select(.focused==true).name' 2>/dev/null)"
    export SESSION=$(i3-msg -t get_tree | jq '
def siblingsOfFocused:
  .nodes? as $kids
  | if ($kids | any(.focused == true)) then
      {
        siblings: $kids,
        index: (
          $kids
          | to_entries
          | map(select(.value.focused == true).key)
          | first
          // -1
        )
      }
    else
      .floating_nodes? as $fkids
      | if ($fkids | any(.focused == true)) then
          {
            siblings: $fkids,
            index: (
              $fkids
              | to_entries
              | map(select(.value.focused == true).key)
              | first
              // -1
            )
          }
        else
          # Recurse deeper into child nodes/floating_nodes 
          ( .nodes[]?, .floating_nodes[]? )
          | siblingsOfFocused
      end
    end;
(siblingsOfFocused) as $result
| $result.index
' 2>/dev/null)
    export WORKSPACE="${WORKSPACE:-unknown}"
else
    # Simple fallback - just use terminal name and random session
    echo "💡 If you had i3, you'd have session records of every shell."
    export WORKSPACE="$(echo "${TERM:-terminal}" | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:]')"
    export SESSION="$RANDOM"
fi

# Ensure log directory exists - configurable location
LOGDIR="${THOMCOM_LOG_DIR:-$HOME/.thomcom_shell/logs}/workspace-$WORKSPACE"
mkdir -p "$LOGDIR"

# Build log filename: YYYY-MM-DD-workspace-<name>
BASEFILE="$(date +%Y-%m-%d)-workspace-$WORKSPACE"

LOGFILE="$LOGDIR/${BASEFILE}-session-${SESSION}.log"

# Show log folder size
echo "Current log size: $(du -sh $(dirname "$LOGDIR") 2>/dev/null | awk '{print $1}')"
echo "Appending log to: $LOGFILE"

# Replace this shell with 'script', appending all output
# Run script with explicit shell command that sets INSIDE_SCRIPT=1
exec script -a -f -q "$LOGFILE" -c "INSIDE_SCRIPT=1 CLAUDECODE= zsh -l"