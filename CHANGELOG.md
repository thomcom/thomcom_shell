# Changelog

## [1.1.0] - 2026-02-15

### Fixed
- **micromamba PATH**: `micromamba activate` in sourced scripts silently failed to update PATH; added explicit `CONDA_PREFIX/bin` fallback
- **prompt.sh**: Conda env prefix `(dev-tools)` was overwritten by hardcoded PS1; now includes env name
- **bash_profile**: Was not sourcing `.bashrc`, so login shells missed all thomcom_shell modules

### Changed
- **conda.sh**: Simplified initialization — removed subshell env list check, direct `micromamba activate` with fallback chain
- **Removed `2>/dev/null`** from `conda.sh`, `fzf.sh`, `atuin.sh`, `system.sh` — errors should be visible, not hidden
- **history.zsh**: Simplified to atuin-first strategy with simple shared history fallback; removed complex session batching
- **options.zsh**: Changed `CORRECT_ALL` to `CORRECT` (command names only, avoids rendering noise)
- **completion.zsh**: Added vi-mode keybindings, menu completion, up/down prefix search, tmux rendering fixes
- **nvm.zsh**: Lazy-loaded — nvm/node/npm/npx only initialize on first use
- **broadcast.zsh**: Auto-cleanup of stale broadcasts (>60s), exact-match pkill
- **session-tracker**: Clear `CONDA_DEFAULT_ENV` before re-exec to avoid double activation; skip inside tmux (zsh)
- **fzf.zsh**: Added fallback history widget (matching bash version) when atuin unavailable
- **system.zsh**: Added capslock remap and touchpad config (matching bash version)

### Added
- **aliases.zsh**: GCP shortcuts — `instances` alias, `gssh` function with tab completion
- **zshrc**: Google Cloud SDK, bun completions, openclaw completion
- **bashrc**: cargo env, Google Cloud SDK integration
- **tools/atuin.zsh**: New file — zsh atuin integration

## [1.0.0] - 2026-02-12

### Added
- **Tiered installation**: `--tier base|shell|full` argument for install.sh
- **Docker support**: `--docker` flag for non-interactive installs; multi-stage Dockerfile with base/shell/full targets
- **VERSION file**: Semantic versioning, exported as `$THOMCOM_SHELL_VERSION`
- **Tier-aware bashrc**: Reads `.tier` file, conditionally loads modules per tier
- **`interactive/aliases-base.sh`**: Universal aliases (ll, la, l, du, ff, exit prevention) available at all tiers
- **git-lfs**: Installed in base tier
- **pip + ipython**: Added to micromamba dev-tools environment

### Changed
- **install.sh**: Refactored into `install_base()` / `install_shell()` / `install_full()` cascading functions
- **interactive/aliases.sh**: Now sources aliases-base.sh first, keeps only machine-specific aliases
- **bashrc**: Module loading is tier-gated via `THOMCOM_TIER` variable
- **tests/test_suite.sh**: Rewritten with tier-aware validation (25 tests)
- **tests/Dockerfile.test**: Uses `--tier full --docker` flags
- **README.md**: Rewritten for current architecture
- **CLAUDE.md**: Updated architecture docs

### Removed
- **kitty terminal**: Removed `tools/kitty.zsh`, `tools/kitty/kitty.conf`, kitty installation block, kitty TERMINFO detection
- Kitty references replaced with alacritty in `core/environment.sh` and `core/environment.zsh`
