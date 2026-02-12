# Changelog

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
