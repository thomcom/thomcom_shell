#!/bin/bash
##############################################################################
# Conda/Mamba Integration (Micromamba)
##############################################################################

# Mamba / Conda setup
export MAMBA_EXE="$HOME/bin/micromamba"
export MAMBA_ROOT_PREFIX="$HOME/data/micromamba/"

# Initialize micromamba shell integration
eval "$("$MAMBA_EXE" shell hook --shell bash --root-prefix "$MAMBA_ROOT_PREFIX")"

# CMake integration with conda
export CMAKE_PREFIX_PATH=$CONDA_PREFIX:$CMAKE_PREFIX_PATH

# Auto-activate dev-tools environment
if [[ -z "$CONDA_DEFAULT_ENV" ]]; then
    micromamba activate dev-tools || micromamba activate micromamba_environment || true
fi

# Ensure activated env bin is on PATH (micromamba activate can miss this in sourced scripts)
if [[ -n "$CONDA_PREFIX" && -d "$CONDA_PREFIX/bin" ]]; then
    case ":$PATH:" in
        *":$CONDA_PREFIX/bin:"*) ;;
        *) export PATH="$CONDA_PREFIX/bin:$PATH" ;;
    esac
fi
