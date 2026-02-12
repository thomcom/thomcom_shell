# .thomcom_shell

Modular shell configuration system with terminal broadcast, session logging, and Claude Code integration.

**Last updated**: 2026-02-12

## What It Does

- **Broadcast system**: `zbc "command"` sends commands to all active terminal sessions via SIGUSR1
- **Session logging**: Every terminal session logged to `~/data/terminal-sessions/` using `script`
- **Modular config**: Core, interactive, tools, logging modules loaded conditionally
- **Tiered install**: `base` (CLI essentials), `shell` (+ atuin, nvm), `full` (+ broadcast, logging, Claude Code)
- **Dev environment**: Installs micromamba, nvm, atuin, Claude Code CLI

## Architecture

```
bashrc (entry point, tier-aware)
├── VERSION              - Semantic version (e.g. 0.1.0)
├── .tier                - Installed tier (base|shell|full)
├── core/
│   ├── environment.sh   - PATH, exports, dev tool config
│   ├── options.sh       - bash options (shopt)
│   └── history.sh       - history config, Atuin integration
├── tools/
│   ├── conda.sh         - micromamba init (base)
│   ├── fzf.sh           - fuzzy finder keybindings (base)
│   ├── atuin.sh         - session-aware history (shell+)
│   ├── nvm.sh           - node version manager (shell+)
│   └── system.sh        - system utilities (full)
├── features/
│   └── broadcast.sh     - zbc() command, SIGUSR1 handling (full)
├── interactive/
│   ├── prompt.sh        - PS1 configuration
│   ├── aliases-base.sh  - universal aliases (base)
│   ├── aliases.sh       - machine-specific aliases (shell+)
│   ├── colors.sh        - terminal colors
│   └── completion.sh    - tab completion
├── logging/
│   ├── session-tracker.sh  - script-based session recording (full)
│   └── replay-tools.sh    - session playback utilities (full)
└── Dockerfile           - Multi-stage build (base/shell/full targets)
```

## Installation

```bash
# Full (default)
./install.sh

# Specific tier
./install.sh --tier base
./install.sh --tier shell

# Docker mode (non-interactive)
./install.sh --tier base --docker
```

## Docker

```bash
docker build --target base  -t thomcom-shell:base  .
docker build --target shell -t thomcom-shell:shell .
docker build --target full  -t thomcom-shell:full  .
```

## Key Files

| File | Purpose |
|------|---------|
| `bashrc` | Main entry point, tier-aware module loading |
| `install.sh` | Tiered installer (--tier base/shell/full --docker) |
| `VERSION` | Semantic version, exported as $THOMCOM_SHELL_VERSION |
| `features/broadcast.sh` | The killer feature - cross-terminal commands |
| `logging/session-tracker.sh` | Uses `script` to log all output |

## Testing

```bash
./tests/test_suite.sh         # Run test suite
./tests/run_docker_tests.sh   # Docker-based testing
```
