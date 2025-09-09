#!/bin/zsh
##############################################################################
# Aliases - Command shortcuts and customizations
##############################################################################

# Basic file operations
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Application customizations
alias emacs='emacs -nw'
alias clang-format='clang-format-11'
alias xclip='xclip -selection clipboard'

# Custom functions as aliases
bitwig() { GDK_SCALE=1 GDK_DPI_SCALE=1.42 /opt/bitwig-studio/bitwig-studio "$@"; }
ff() { /usr/bin/find . -name "$1"; }

# Alert notification
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" \
  "$(history | tail -n1 | sed -e "s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//")"'

# Work-specific aliases loaded separately

# CUDA version switching
alias use-cuda12='export PATH=/usr/local/cuda-12.4/bin${PATH:+:${PATH}} && export LD_LIBRARY_PATH=/usr/local/cuda-12.4/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}'
alias use-cuda11='export PATH=/usr/local/cuda-11.8/bin${PATH:+:${PATH}} && export LD_LIBRARY_PATH=/usr/local/cuda-11.8/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}'

# GitLab CI shortcut
alias gcl='gitlab-ci-local'

# Exit prevention (use logout to exit)
alias exit="echo Use 'logout' to exit"

# Sensible du defaults
du() {
    command du -h -d 1 -- "$@"
}

# Load custom aliases if available
[[ -f ~/.zsh_aliases ]] && source ~/.zsh_aliases