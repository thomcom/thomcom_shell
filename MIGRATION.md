# Migration Guide

## For Existing Users (Breaking Changes)

### Secrets Directory Change (v2.0.0)

**BREAKING CHANGE**: The hardcoded `~/.nvidia/` directory has been replaced with a configurable `THOMCOM_SECRETS_DIR` variable.

#### What Changed:
- **Old**: Files were hardcoded to `~/.nvidia/work.zsh` and `~/.nvidia/keys.sh`
- **New**: Files use `$THOMCOM_SECRETS_DIR/work.zsh` and `$THOMCOM_SECRETS_DIR/keys.sh`
- **Default**: `THOMCOM_SECRETS_DIR` defaults to `~/.secrets/`

#### Migration Steps:

1. **Keep existing setup** (recommended for existing users):
   ```bash
   echo 'export THOMCOM_SECRETS_DIR="$HOME/.nvidia"' >> ~/.bashrc
   echo 'export THOMCOM_SECRETS_DIR="$HOME/.nvidia"' >> ~/.zshrc
   ```

2. **Or migrate to new default**:
   ```bash
   mkdir -p ~/.secrets
   mv ~/.nvidia/work.zsh ~/.secrets/work.zsh 2>/dev/null || true
   mv ~/.nvidia/keys.sh ~/.secrets/keys.sh 2>/dev/null || true
   ```

3. **Update any custom scripts** that referenced `~/.nvidia/` paths

#### Function Name Changes:
- **Old**: `_nvidia_startup()` 
- **New**: `_work_startup()`

Update your work configuration file:
```bash
# In your work.zsh file, rename:
_nvidia_startup() {     # OLD
_work_startup() {       # NEW
```

### Test Structure Changes

- **Old**: `test_modular_shell.sh` and `test_in_docker.sh` in root
- **New**: Single `./tests/test_suite.sh` 

Update any automation that referenced the old test files.

## Benefits of Changes

✅ **Universal compatibility** - No longer tied to specific company  
✅ **Configurable paths** - Easy to customize for any environment  
✅ **Cleaner structure** - Single test suite, better organization  
✅ **Professional naming** - Generic function and directory names