#!/bin/zsh
##############################################################################
# Conda/Mamba Integration
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