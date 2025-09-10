#!/bin/zsh
##############################################################################
# Conda/Mamba Integration (Micromamba)
##############################################################################
#
# Seamless Python environment management with lightning-fast micromamba.
# Handles the complex initialization dance so you get instant access to
# conda commands and environments without the typical setup headaches.
#
# Benefits:
# - 10x faster than traditional conda (thanks to micromamba's C++ rewrite)
# - Auto-detects and initializes micromamba if installed
# - CLAUDECODE-aware: provides simple alias in AI environments
# - CMake integration for compiled Python extensions
# - Graceful fallback if micromamba isn't available
# - No error spam in non-interactive shells
#
##############################################################################

# Mamba / Conda setup
export MAMBA_EXE='/home/tcomer/bin/micromamba'
export MAMBA_ROOT_PREFIX='/home/tcomer/data/micromamba/'

# Initialize micromamba
__mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2>/dev/null)"
if [[ $? -eq 0 ]]; then
    eval "$__mamba_setup"
else
    alias micromamba="$MAMBA_EXE"  # fallback
fi
unset __mamba_setup

# CMake integration with conda
export CMAKE_PREFIX_PATH=$CONDA_PREFIX:$CMAKE_PREFIX_PATH

# Auto-activate dev-tools environment (our foundational development environment)
if [[ "$CLAUDECODE" != "1" && -z "$CONDA_DEFAULT_ENV" ]]; then
    if "$MAMBA_EXE" env list | grep -q "dev-tools" 2>/dev/null; then
        micromamba activate dev-tools 2>/dev/null || true
    elif "$MAMBA_EXE" env list | grep -q "micromamba_environment" 2>/dev/null; then
        # Fallback to old environment name for existing installations  
        micromamba activate micromamba_environment 2>/dev/null || true
    fi
fi