# thomcom Shell

Modular bash shell configuration with tiered installation, terminal broadcast, session logging, and Claude Code integration.

## Quick Start

```bash
git clone https://github.com/thomcom/thomcom-shell.git ~/.thomcom_shell
cd ~/.thomcom_shell && ./install.sh
```

## Installation Tiers

| Tier | What you get |
|------|-------------|
| `base` | bash, git, git-lfs, micromamba (neovim, rg, fd, fzf, jq, python 3.11, pip, ipython), vim-plug, base aliases, completion |
| `shell` | Everything in base + atuin (session-aware history), nvm + Node LTS, machine-specific aliases |
| `full` | Everything in shell + broadcast system, session logging, Claude Code CLI **(default)** |

```bash
./install.sh                        # full (default)
./install.sh --tier base            # minimal CLI
./install.sh --tier shell           # interactive dev shell
./install.sh --tier base --docker   # non-interactive for containers
```

## Docker

```bash
docker build --target base  -t thomcom-shell:base  .
docker build --target shell -t thomcom-shell:shell .
docker build --target full  -t thomcom-shell:full  .
```

## Features

### Broadcast

Send commands to all active terminal sessions:

```bash
zbc "export API_KEY=abc123"           # Set env var everywhere
zbc "cd ~/project && git pull"        # Sync all terminals
zbc "micromamba activate newenv"       # Activate env everywhere
```

### Session Logging

Every terminal session is recorded to `~/data/terminal-sessions/` using `script`. Replay with built-in tools.

### Tiered Module Loading

bashrc reads `~/.thomcom_shell/.tier` and conditionally loads modules. `$THOMCOM_TIER` and `$THOMCOM_SHELL_VERSION` are exported for scripts to use.

## Architecture

```
bashrc (entry point, tier-aware)
├── core/           environment, options, history (all tiers)
├── tools/          conda, fzf (base) | atuin, nvm (shell+) | system (full)
├── features/       broadcast (full)
├── interactive/    colors, prompt, aliases-base (base) | aliases (shell+) | completion
└── logging/        session-tracker, replay-tools (full)
```

## Testing

```bash
bash tests/test_suite.sh
```

## License

MIT
