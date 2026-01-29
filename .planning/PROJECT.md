# .thomcom_shell → bash Migration

## What This Is

Shell configuration system being migrated from zsh to bash. The broadcast system (`zbc`), session logging, and modular config structure stay - the zsh-specific syntax and "helpful" interactive features go.

## Core Value

**Universal, non-interruptive shell configuration.** bash works everywhere. No y/n prompts, no arrow-key selections, no spell corrections - pure text/stream mode.

## Requirements

### Validated

- ✓ Broadcast system (`zbc`) works — existing
- ✓ Session logging via `script` — existing
- ✓ Modular config structure — existing
- ✓ Claude Code integration — existing
- ✓ Dev environment setup (micromamba, nvm, atuin) — existing

### Active

- [ ] All `.zsh` files converted to `.sh`/`.bash`
- [ ] `zshrc` becomes `bashrc`
- [ ] `setopt` → `shopt` equivalents
- [ ] `precmd` → `PROMPT_COMMAND`
- [ ] `TRAPUSR1`/`TRAPEXIT` → `trap` commands
- [ ] zsh arrays → bash arrays
- [ ] `[[ -o interactive ]]` → `[[ $- == *i* ]]`
- [ ] Completion system → bash-completion
- [ ] Installer updated to configure bash instead of zsh
- [ ] All zsh "helpful" features removed (no corrections, no y/n, no menus)
- [ ] Tests pass on bash

### Out of Scope

- Adding new features — migration only
- Supporting both shells simultaneously — clean break to bash
- Preserving zsh-specific niceties — that's the point

## Context

**Why the migration:**
- zsh "features" interrupt flow: spell correction, y/n prompts, arrow-key menus
- These break text/stream mode - the opposite of helpful
- bash is universal, zsh adoption is minimal
- .thomcom_shell should work everywhere without special shell installs

**Current state:**
- 100% zsh-based (`.zsh` extensions, zsh syntax throughout)
- Installer sets zsh as default shell
- Last commit: 2025-11-18

**Key conversions needed:**
| zsh | bash |
|-----|------|
| `setopt` | `shopt` |
| `precmd` | `PROMPT_COMMAND` |
| `TRAPUSR1` | `trap '...' USR1` |
| `TRAPEXIT` | `trap '...' EXIT` |
| `[[ -o interactive ]]` | `[[ $- == *i* ]]` |
| `${(k)hash}` | `${!hash[@]}` |
| `functions[name]` | `declare -f name` |

## Constraints

- **Compatibility**: Must work on Ubuntu, Debian, macOS (bash 3.2+)
- **No new deps**: Don't add dependencies, only remove zsh
- **Preserve behavior**: broadcast, logging, modular loading must work identically

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Clean break to bash | No shell detection complexity, simpler maintenance | — Pending |
| Rename all files | `.zsh` → `.sh` makes intent clear | — Pending |

---
*Last updated: 2026-01-28 after initialization*
