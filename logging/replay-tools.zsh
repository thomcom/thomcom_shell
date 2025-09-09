#!/bin/zsh
##############################################################################
# Session Replay Tools - Functions for viewing and replaying terminal sessions
##############################################################################

# Better session replays
view_session () {
    LC_ALL=C \
    sed -E $'s/\x1B\\[[0-?]*[ -\\/]*[@-~]//g' "$1" |   # drop ANSI CSI sequences
    tr -d '\r\a' |                                     # zap ^M and ^G
    less -FX                                           # page (-F quits if one screen, -X keeps screen on exit)
}

# replay  LOGFILE  [lines_per_chunk]
#         ^^^^^^^  default = 50
replay () {
    [[ -r $1 ]] || { echo "usage: replay LOGFILE [chunk]" >&2; return 1; }

    local log=$1
    local lines=${2:-50}

    scriptreplay <(
        awk -v L="$lines" '
            { bytes += length($0 ORS); count++ }
            (count==L) {
                printf "0 %.0f\n", bytes; bytes = 0; count = 0
            }
            END { if (bytes) printf "0 %.0f\n", bytes }
        ' "$log"
    )  "$log"
}