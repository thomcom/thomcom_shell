# .thomcom_shell

Modular shell configuration system with terminal broadcast, session logging, and Claude Code integration.

**Last updated**: 2026-01-28 (Git last commit: 2025-11-18 - README.md and this file may need updates)

## What It Does

- **Broadcast system**: `zbc "command"` sends commands to all active terminal sessions via SIGUSR1
- **Session logging**: Every terminal session logged to `~/data/terminal-sessions/` using `script`
- **Modular config**: Core, interactive, tools, logging modules loaded conditionally
- **Dev environment**: Installs micromamba, nvm, atuin, kitty, Claude Code CLI

## Architecture

```
zshrc (entry point)
├── core/
│   ├── environment.zsh  - PATH, exports, dev tool config
│   ├── options.zsh      - zsh options (setopt)
│   └── history.zsh      - history config, Atuin integration
├── tools/
│   ├── conda.zsh        - micromamba init
│   ├── nvm.zsh          - node version manager
│   ├── fzf.zsh          - fuzzy finder keybindings
│   ├── atuin.zsh        - session-aware history
│   ├── kitty.zsh        - terminal config
│   └── system.zsh       - system utilities
├── features/
│   └── broadcast.zsh    - zbc() command, SIGUSR1 handling
├── interactive/
│   ├── prompt.zsh       - PS1 configuration
│   ├── aliases.zsh      - shell aliases
│   ├── colors.zsh       - terminal colors
│   └── completion.zsh   - tab completion
└── logging/
    ├── session-tracker.zsh  - script-based session recording
    └── replay-tools.zsh     - session playback utilities
```

## Key Files

| File | Purpose |
|------|---------|
| `zshrc` | Main entry point, sources modules |
| `install.sh` | Full installer (bash script) |
| `features/broadcast.zsh` | The killer feature - cross-terminal commands |
| `logging/session-tracker.zsh` | Uses `script` to log all output |

## Testing

```bash
./tests/test_suite.sh         # Run test suite
./tests/run_docker_tests.sh   # Docker-based testing
```

## Current State

- **Shell**: zsh (migration to bash planned)
- **zsh-specific features**:
  - `setopt` calls in options.zsh
  - `precmd` hooks in broadcast.zsh
  - `TRAPEXIT`/`TRAPUSR1` signal handlers
  - zsh-style arrays and expansion
  - `[[ -o interactive ]]` tests
  - zsh completion system

## Migration Notes (zsh → bash)

Key differences to address:
1. `setopt` → `shopt` equivalents
2. `precmd` → `PROMPT_COMMAND`
3. `TRAPEXIT`/`TRAPUSR1` → `trap` commands
4. `[[ -o interactive ]]` → `[[ $- == *i* ]]`
5. Array syntax differences
6. Completion system (bash-completion instead)
7. Module naming: `.zsh` → `.bash` or `.sh`
