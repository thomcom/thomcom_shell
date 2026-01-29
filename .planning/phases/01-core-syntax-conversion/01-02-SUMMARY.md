---
phase: 01-core-syntax-conversion
plan: 02
subsystem: tooling-integration
tags: [bash, zsh-migration, fzf, atuin, completion, broadcast]
requires:
  - 01-01-PLAN
provides:
  - bash-compatible tool integrations
  - readline-based history widgets
  - bash-completion system
  - broadcast system foundation
affects:
  - 01-03-PLAN (logging/interactive files depend on these patterns)
  - 02-PLAN (signal handlers need these files as base)
tech-stack:
  added: []
  patterns:
    - readline for line editing (READLINE_LINE, READLINE_POINT)
    - bind -x for custom key bindings
    - bash-completion for tab completion
    - shopt for shell options
    - trap for signal handling (stubbed for Phase 2)
key-files:
  created:
    - tools/conda.sh
    - tools/kitty.sh
    - tools/atuin.sh
    - tools/fzf.sh
    - interactive/completion.sh
    - features/broadcast.sh
  modified: []
decisions:
  - id: readline-bindings
    choice: Use READLINE_LINE/READLINE_POINT for bash line editing
    rationale: Direct bash equivalent to zsh's LBUFFER
    alternatives: [Custom line manipulation]
  - id: broadcast-stubbing
    choice: Stub signal handlers (trap) for Phase 2
    rationale: Focus this phase on syntax, Phase 2 on behavior
    alternatives: [Implement signals now]
  - id: completion-system
    choice: Use bash-completion, remove zsh compinit
    rationale: bash-completion is standard for bash
    alternatives: [Custom completion framework]
metrics:
  duration: 2min
  completed: 2026-01-29
---

# Phase 01 Plan 02: Tool Integration & Broadcast Conversion Summary

**One-liner**: Converted 6 complex tool integration files from zsh to bash with readline bindings and signal handler stubs

## What Was Accomplished

### Tool Initializations (Task 1)
Converted micromamba, kitty, and atuin integrations:
- **conda.sh**: Changed micromamba init to `--shell bash`
- **kitty.sh**: Converted zsh path expansion `${0:A:h}` to bash `$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)`
- **atuin.sh**: Changed to `atuin init bash`, converted zle to readline bindings

### Complex Features (Task 2)
Converted fzf, completion system, and broadcast:
- **fzf.sh**: Readline history widget, removed zsh-specific constructs
- **completion.sh**: Replaced zsh completion system with bash-completion
- **broadcast.sh**: Signal handlers (trap) stubbed with TODO comments for Phase 2

## Key Technical Changes

### Readline Line Editing
Replaced zsh line editor (zle) with bash readline:
```bash
# Before (zsh)
LBUFFER="$selected"
zle reset-prompt

# After (bash)
READLINE_LINE="$selected"
READLINE_POINT=${#READLINE_LINE}
```

### Key Bindings
Replaced zsh bindkey with bash bind:
```bash
# Before (zsh)
zle -N fzf-history-widget
bindkey '^R' fzf-history-widget

# After (bash)
bind -x '"\C-r": fzf-history-widget'
```

### Shell Option Management
Replaced setopt with shopt:
```bash
# Before (zsh)
setopt NULL_GLOB
# ... code ...
unsetopt NULL_GLOB

# After (bash)
shopt -s nullglob
# ... code ...
shopt -u nullglob
```

### Signal Handlers (Stubbed)
Marked for Phase 2 implementation:
```bash
# TODO Phase 2: trap '_check_broadcasts' USR1
# TODO Phase 2: trap '_cleanup_broadcast_state' EXIT
```

## Test Results

All files pass `bash -n` syntax validation:
```bash
bash -n tools/conda.sh      # ✓
bash -n tools/kitty.sh      # ✓
bash -n tools/atuin.sh      # ✓
bash -n tools/fzf.sh        # ✓
bash -n interactive/completion.sh  # ✓
bash -n features/broadcast.sh     # ✓
```

Verification checks:
- ✓ No zsh-specific constructs remain (setopt, zle, bindkey, compdef, compinit)
- ✓ Tool initializations use `--shell bash` or `init bash`
- ✓ 6 new .sh files exist with correct bash syntax

## Deviations from Plan

None - plan executed exactly as written.

## Next Phase Readiness

**Ready for Phase 01-03**: Logging and interactive files
**Blocked**: None
**Concerns**: Signal handlers need implementation in Phase 2 for broadcast to function

## Files Changed

| File | Lines | Description |
|------|-------|-------------|
| tools/conda.sh | 60 | Micromamba init with --shell bash |
| tools/kitty.sh | 36 | Bash path expansion for config symlink |
| tools/atuin.sh | 57 | Atuin init bash with readline |
| tools/fzf.sh | 56 | Readline history widget, no zle |
| interactive/completion.sh | 22 | bash-completion system |
| features/broadcast.sh | 114 | Signal handlers stubbed for Phase 2 |

## Commits

- e39a8ee: feat(01-02): convert tool initialization to bash
- ad79f4b: feat(01-02): convert fzf, completion, and broadcast to bash
