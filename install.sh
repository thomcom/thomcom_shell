#!/bin/bash
##############################################################################
# thomcom Shell Installer
# Installs and configures the modular bash shell system
#
# Usage: ./install.sh [--tier base|shell|full] [--docker]
# Default: --tier full
##############################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration - determine location from script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHELL_DIR="$SCRIPT_DIR"

# Defaults
TIER="full"
DOCKER_MODE=0

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --tier)
            TIER="$2"
            shift 2
            ;;
        --docker)
            DOCKER_MODE=1
            shift
            ;;
        -h|--help)
            echo "Usage: ./install.sh [--tier base|shell|full] [--docker]"
            echo "  --tier   Installation tier: base, shell, or full (default: full)"
            echo "  --docker Skip interactive prompts and X11 tools"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Validate tier
case "$TIER" in
    base|shell|full) ;;
    *) echo "Invalid tier: $TIER (must be base, shell, or full)"; exit 1 ;;
esac

# Read version
VERSION="unknown"
[[ -f "$SHELL_DIR/VERSION" ]] && VERSION="$(< "$SHELL_DIR/VERSION")" && VERSION="${VERSION%$'\n'}"

# Helper functions
info() { echo -e "${BLUE}ℹ $1${NC}"; }
success() { echo -e "${GREEN}✓ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
error() { echo -e "${RED}✗ $1${NC}"; exit 1; }

has_command() {
    command -v "$1" >/dev/null 2>&1
}

##############################################################################
# TIER: base — Usable CLI with good defaults
##############################################################################
install_base() {
    info "Installing base tier..."

    # Check prerequisites
    success "bash found: $(bash --version | head -n1)"

    if ! has_command git; then
        error "Git is required but not installed. Please install git first."
    fi
    success "Git found"

    # git-lfs
    if ! has_command git-lfs; then
        info "Installing git-lfs..."
        if has_command apt-get; then
            sudo apt-get install -y git-lfs 2>/dev/null || warning "Could not install git-lfs via apt"
        fi
    fi
    if has_command git-lfs; then
        git lfs install --skip-smudge 2>/dev/null || true
        success "git-lfs configured"
    fi

    # Install micromamba
    info "Setting up micromamba..."
    if ! has_command micromamba; then
        info "Installing micromamba..."
        curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest | tar -xvj bin/micromamba
        mkdir -p "$HOME/bin"
        mv bin/micromamba "$HOME/bin/"
        rmdir bin 2>/dev/null || true
        export MAMBA_EXE="$HOME/bin/micromamba"
        export MAMBA_ROOT_PREFIX="$HOME/data/micromamba"
        export PATH="$HOME/bin:$PATH"
        success "Micromamba installed"
    else
        success "Micromamba already available"
        export MAMBA_EXE="$HOME/bin/micromamba"
        export MAMBA_ROOT_PREFIX="$HOME/data/micromamba"
    fi

    # Clean micromamba state
    unset CONDA_PREFIX CONDA_DEFAULT_ENV
    export CONDARC=""

    if [[ ! -d "$MAMBA_ROOT_PREFIX" ]]; then
        mkdir -p "$MAMBA_ROOT_PREFIX"
    fi
    chmod 755 "$MAMBA_ROOT_PREFIX" 2>/dev/null || true

    if ! "$MAMBA_EXE" --version >/dev/null 2>&1; then
        error "Micromamba installation failed at: $MAMBA_EXE"
    fi

    # Create dev-tools environment
    if ! "$MAMBA_EXE" env list 2>/dev/null | grep -q "dev-tools"; then
        info "Creating dev-tools environment (python, neovim, fzf, ripgrep, fd, jq, pip, ipython)..."
        if "$MAMBA_EXE" create -n dev-tools -c conda-forge \
            python=3.11 \
            pip \
            ipython \
            neovim \
            fzf \
            fd-find \
            ripgrep \
            jq \
            -y 2>/dev/null; then
            success "dev-tools environment created"
        else
            warning "Some dev-tools packages may not be available"
        fi
    else
        success "dev-tools environment already exists"
    fi

    # vim-plug for neovim
    if [[ ! -f "$HOME/.local/share/nvim/site/autoload/plug.vim" ]]; then
        info "Installing vim-plug for neovim..."
        curl -fLo "$HOME/.local/share/nvim/site/autoload/plug.vim" --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim 2>/dev/null
        success "vim-plug installed"
    fi

    # Set up bashrc symlink
    if [[ -f "$HOME/.bashrc" && ! -L "$HOME/.bashrc" ]]; then
        info "Backing up existing .bashrc to .bashrc.backup"
        cp "$HOME/.bashrc" "$HOME/.bashrc.backup"
        success "Backup created"
    fi
    rm -f "$HOME/.bashrc"
    ln -s "$SHELL_DIR/bashrc" "$HOME/.bashrc"
    success "Symlink created: ~/.bashrc -> ~/.thomcom_shell/bashrc"

    # Store tier
    echo "$TIER" > "$SHELL_DIR/.tier"
    success "Tier set to: $TIER"

    success "Base tier installed"
}

##############################################################################
# TIER: shell — Full interactive shell with history + node
##############################################################################
install_shell() {
    install_base

    info "Installing shell tier..."

    # Atuin (session-aware shell history)
    if ! has_command atuin; then
        info "Installing Atuin (shell history)..."
        curl --proto '=https' --tlsv1.2 -LsSf https://github.com/atuinsh/atuin/releases/latest/download/atuin-installer.sh | sh -s -- -q
        [[ -f "$HOME/.atuin/bin/env" ]] && source "$HOME/.atuin/bin/env"
        if has_command atuin; then
            success "Atuin installed"
            if [[ -f "$HOME/.bash_history" ]]; then
                info "Importing existing shell history..."
                atuin import auto 2>/dev/null || true
                success "History imported"
            fi
        else
            warning "Atuin installation failed - history will use fallback mode"
        fi
    else
        success "Atuin already available"
    fi

    # NVM + Node LTS
    if [[ ! -d "$HOME/.nvm" ]]; then
        info "Installing NVM..."
        export NVM_DIR="$HOME/.nvm"
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
        success "NVM installed"
    else
        success "NVM already available"
    fi

    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

    if ! has_command node; then
        info "Installing Node.js LTS via NVM..."
        nvm install --lts
        nvm use --lts
        success "Node.js installed: $(node --version)"
    else
        success "Node.js already available: $(node --version)"
    fi

    success "Shell tier installed"
}

##############################################################################
# TIER: full — Complete environment (DEFAULT)
##############################################################################
install_full() {
    install_shell

    info "Installing full tier..."

    # Broadcast directory
    mkdir -p "$HOME/.bash_broadcasts"
    success "Broadcast directory created"

    # Claude Code CLI
    if ! has_command claude; then
        info "Installing Claude Code CLI..."
        npm install -g @anthropic-ai/claude-code
        success "Claude Code installed"
    else
        success "Claude Code already available"
    fi

    # Work-specific configuration
    SECRETS_DIR="${THOMCOM_SECRETS_DIR:-$HOME/.secrets}"
    if [[ ! -d "$SECRETS_DIR" ]]; then
        mkdir -p "$SECRETS_DIR"
        info "Created $SECRETS_DIR directory"
        cat > "$SECRETS_DIR/work.sh" << 'EOF'
#!/bin/bash
##############################################################################
# Work-Specific Configuration
# Add your company/work-specific settings here
##############################################################################

# Example: Internal network hosts
# export INTERNAL_HOST=10.0.0.1

# Example: Work-specific aliases
# alias deploy='./scripts/deploy.sh'

# Example: Startup commands (called automatically if defined)
# _work_startup() {
#     cd ~/work/projects
#     micromamba activate work-env
# }
EOF
        info "Created template work configuration at $SECRETS_DIR/work.sh"
    fi

    success "Full tier installed"
}

##############################################################################
# Main
##############################################################################
main() {
    echo -e "${BLUE}🚀 thomcom Shell Installer v${VERSION} [tier: ${TIER}]${NC}\n"

    # Update repository if we're in a git repo (skip in docker)
    if [[ "$DOCKER_MODE" -eq 0 && -d "$SHELL_DIR/.git" ]]; then
        cd "$SHELL_DIR"
        git pull 2>/dev/null || info "No git updates available"
        success "Repository updated"
    fi

    case "$TIER" in
        base)  install_base ;;
        shell) install_shell ;;
        full)  install_full ;;
    esac

    info "🏗️ Architecture: OS → APT (minimal) → Micromamba → dev-tools → project envs"
    success "Development environment isolation complete!"

    # Run tests (skip in docker to avoid circular dependency)
    if [[ "$DOCKER_MODE" -eq 0 && -f "$SHELL_DIR/tests/test_suite.sh" ]]; then
        info "Running installation tests..."
        if "$SHELL_DIR/tests/test_suite.sh" >/dev/null 2>&1; then
            success "All tests passed"
        else
            warning "Some tests failed - installation may have issues"
        fi
    fi

    echo -e "\n${GREEN}🎉 Installation completed successfully! (v${VERSION}, tier: ${TIER})${NC}\n"

    if [[ "$DOCKER_MODE" -eq 0 ]]; then
        echo "Starting bash with your new configuration..."
        echo
        echo "Documentation: $SHELL_DIR/README.md"
        echo
        exec bash -c "source ~/.bashrc; exec bash"
    fi
}

# Check if running as root (allow in docker)
if [[ $EUID -eq 0 && "$DOCKER_MODE" -eq 0 ]]; then
    error "This script should not be run as root"
fi

main "$@"
