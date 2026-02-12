#!/bin/bash
##############################################################################
# Aliases - Machine-specific command shortcuts
# Loads base aliases first, then adds machine-specific ones
##############################################################################

# Load base aliases (available at all tiers)
[[ -f "$THOMCOM_SHELL_ROOT/interactive/aliases-base.sh" ]] && source "$THOMCOM_SHELL_ROOT/interactive/aliases-base.sh"

# Application customizations
alias emacs='emacs -nw'
alias clang-format='clang-format-11'
alias xclip='xclip -selection clipboard'

# Bitwig with HiDPI scaling
bitwig() { GDK_SCALE=1 GDK_DPI_SCALE=1.42 /opt/bitwig-studio/bitwig-studio "$@"; }

# Alert notification
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" \
  "$(history | tail -n1 | sed -e "s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//")"'

# CUDA version switching
alias use-cuda12='export PATH=/usr/local/cuda-12.4/bin${PATH:+:${PATH}} && export LD_LIBRARY_PATH=/usr/local/cuda-12.4/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}'
alias use-cuda11='export PATH=/usr/local/cuda-11.8/bin${PATH:+:${PATH}} && export LD_LIBRARY_PATH=/usr/local/cuda-11.8/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}'

# GitLab CI shortcut
alias gcl='gitlab-ci-local'

# GCP shortcuts
alias instances='gcloud compute instances list --zone=us-central1-a'

# gssh: SSH to GCE instance
gssh() {
    local instance="$1"
    shift 2>/dev/null
    gcloud compute ssh "$instance" --zone=us-central1-a "$@"
}
