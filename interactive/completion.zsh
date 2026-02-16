#!/bin/zsh
##############################################################################
# Completion System + Terminal Settings
# Consolidated config for zsh vi-mode, tmux, xfce4-terminal, local & remote
##############################################################################

[[ ! -o interactive ]] && return

# ── Completion ──────────────────────────────────────────────
zstyle :compinstall filename "$HOME/.zshrc"
autoload -Uz compinit
compinit

# Menu-driven completion
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# ── Vi mode (set in core/options.zsh, bindings here) ───────
bindkey -v

# 10ms key sequence timeout — fast Esc without breaking multi-key combos
KEYTIMEOUT=1

# Restore essential emacs bindings that vi mode removes
bindkey '^R' history-incremental-search-backward
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^K' kill-line
bindkey '^U' backward-kill-line
bindkey '^W' backward-kill-word
bindkey '^?' backward-delete-char
bindkey '^H' backward-delete-char

# Shift+Enter inserts newline without executing (multiline commands)
_insert_newline() { LBUFFER+=$'\n'; }
zle -N _insert_newline
bindkey '^[[13;2u' _insert_newline

# Tab/shift-tab for menu navigation
bindkey '^I' complete-word
bindkey '^[[Z' reverse-menu-complete

# Up/down search based on what's already typed
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
bindkey -M vicmd 'k' up-line-or-beginning-search
bindkey -M vicmd 'j' down-line-or-beginning-search

# ── Terminal rendering (tmux + xfce4-terminal) ─────────────
# These prevent the "tab complete doesn't render" and
# "characters at wrong time" issues in tmux with vi mode

setopt always_last_prompt   # keep cursor on prompt line after completion list
setopt prompt_cr            # print CR before prompt (fixes overwrite artifacts)
setopt prompt_sp            # preserve partial line output (show % marker)
setopt no_flow_control      # disable ^S/^Q (they freeze the terminal in tmux)

# ── Kubernetes completion (lazy) ───────────────────────────
if command -v kubectl &>/dev/null; then
    source <(kubectl completion zsh)
    alias k=kubectl
    compdef _kubectl k
fi
