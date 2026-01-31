#!/bin/bash
##############################################################################
# thomcom Shell Installer
# Installs and configures the modular bash shell system
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
REPO_URL="https://github.com/thomcom/thomcom-shell.git"  # Only used for remote installs

# Helper functions
info() { echo -e "${BLUE}ℹ $1${NC}"; }
success() { echo -e "${GREEN}✓ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
error() { echo -e "${RED}✗ $1${NC}"; exit 1; }

# Check if command exists
has_command() {
    command -v "$1" >/dev/null 2>&1
}

# Main installation function
main() {
    echo -e "${BLUE}🚀 thomcom Shell Installer${NC}\n"
    
    # Check prerequisites
    info "Checking prerequisites..."
    
    # bash is always available on Linux/Unix systems - no installation needed
    success "bash found: $(bash --version | head -n1)"

    # Check for git
    if ! has_command git; then
        error "Git is required but not installed. Please install git first."
    fi
    success "Git found"
    
    # Install micromamba first - the foundation of our development environment
    info "Setting up micromamba (foundational package manager)..."
    
    if ! has_command micromamba; then
        info "Installing micromamba..."
        
        # Download and install micromamba
        curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest | tar -xvj bin/micromamba
        mkdir -p "$HOME/bin"
        mv bin/micromamba "$HOME/bin/"
        rmdir bin 2>/dev/null || true
        
        # Set up micromamba environment
        export MAMBA_EXE="$HOME/bin/micromamba"
        export MAMBA_ROOT_PREFIX="$HOME/data/micromamba/"
        
        # Add to PATH for this session
        export PATH="$HOME/bin:$PATH"
        
        success "Micromamba installed successfully"
    else
        success "Micromamba already available"
        # Don't use existing micromamba - use our own installation for consistency
        export MAMBA_EXE="$HOME/bin/micromamba"
        export MAMBA_ROOT_PREFIX="$HOME/data/micromamba"
    fi
    
    # Force clean micromamba configuration for this session
    unset CONDA_PREFIX CONDA_DEFAULT_ENV
    export CONDARC=""  # Disable any existing conda config
    
    # Ensure micromamba root directory exists with proper permissions
    if [[ ! -d "$MAMBA_ROOT_PREFIX" ]]; then
        mkdir -p "$MAMBA_ROOT_PREFIX"
        info "Created micromamba root directory: $MAMBA_ROOT_PREFIX"
    fi
    
    # Fix permissions if needed
    chmod 755 "$MAMBA_ROOT_PREFIX" 2>/dev/null || true
    
    # Verify micromamba is working
    if ! "$MAMBA_EXE" --version >/dev/null 2>&1; then
        error "Micromamba installation failed or not accessible at: $MAMBA_EXE"
    fi
    
    # Install NVM (Node Version Manager)
    if [[ ! -d "$HOME/.nvm" ]]; then
        info "Installing NVM..."
        export NVM_DIR="$HOME/.nvm"
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
        success "NVM installed"
    else
        success "NVM already available"
    fi

    # Load NVM for this session
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

    # Install Node LTS via NVM
    if ! has_command node; then
        info "Installing Node.js LTS via NVM..."
        nvm install --lts
        nvm use --lts
        success "Node.js installed: $(node --version)"
    else
        success "Node.js already available: $(node --version)"
    fi

    # Install Claude Code CLI
    if ! has_command claude; then
        info "Installing Claude Code CLI..."
        npm install -g @anthropic-ai/claude-code
        success "Claude Code installed"
    else
        success "Claude Code already available"
    fi

    # Install Atuin (session-aware shell history)
    if ! has_command atuin; then
        info "Installing Atuin (shell history)..."
        # Use direct installer with quiet mode - skip the wrapper that modifies shell configs
        curl --proto '=https' --tlsv1.2 -LsSf https://github.com/atuinsh/atuin/releases/latest/download/atuin-installer.sh | sh -s -- -q

        # Add to PATH for this session
        [[ -f "$HOME/.atuin/bin/env" ]] && source "$HOME/.atuin/bin/env"

        if has_command atuin; then
            success "Atuin installed"

            # Import existing history if available
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

    # Install vim-plug for neovim (lightweight setup)
    if [[ ! -f "$HOME/.local/share/nvim/site/autoload/plug.vim" ]]; then
        info "Installing vim-plug for neovim..."
        curl -fLo "$HOME/.local/share/nvim/site/autoload/plug.vim" --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim 2>/dev/null
        success "vim-plug installed"
    fi

    # Install kitty terminal (GPU-accelerated, supports vim scrollback)
    if ! has_command kitty; then
        info "Installing kitty terminal..."
        if has_command apt-get; then
            sudo apt-get install -y kitty
        elif has_command pacman; then
            sudo pacman -S --noconfirm kitty
        elif has_command brew; then
            brew install --cask kitty
        else
            warning "Could not install kitty automatically. Install manually if desired."
        fi
        if has_command kitty; then
            success "Kitty installed: $(kitty --version)"
        fi
    else
        success "Kitty already available: $(kitty --version)"
    fi

    # Set up kitty config symlink
    if has_command kitty; then
        info "Configuring kitty terminal..."
        mkdir -p "$HOME/.config/kitty"
        if [[ ! -L "$HOME/.config/kitty/kitty.conf" ]]; then
            if [[ -f "$HOME/.config/kitty/kitty.conf" ]]; then
                mv "$HOME/.config/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf.backup"
                info "Backed up existing kitty.conf"
            fi
            ln -s "$SHELL_DIR/tools/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
        fi
        success "Kitty configured with vim-style scrollback (ctrl+shift+h)"
    fi
    
    info "Note: dev-tools environment will be created automatically on first shell startup"
    
    info "🏗️ Architecture: OS → APT/Brew (minimal) → Micromamba → dev-tools → project envs"
    success "Development environment isolation complete!"
    
    # Backup existing .bashrc
    if [[ -f "$HOME/.bashrc" && ! -L "$HOME/.bashrc" ]]; then
        info "Backing up existing .bashrc to .bashrc.backup"
        cp "$HOME/.bashrc" "$HOME/.bashrc.backup"
        success "Backup created"
    fi
    
    # Update repository if we're in a git repo
    info "Setting up from repository at: $SHELL_DIR"
    if [[ -d "$SHELL_DIR/.git" ]]; then
        cd "$SHELL_DIR"
        git pull 2>/dev/null || info "No git updates available (offline or already current)"
        success "Repository updated"
    else
        success "Using local files (not a git repository)"
    fi
    
    # Create symlink
    info "Setting up .bashrc symlink..."
    rm -f "$HOME/.bashrc"  # Remove existing file or symlink
    ln -s "$SHELL_DIR/bashrc" "$HOME/.bashrc"
    success "Symlink created: ~/.bashrc -> ~/.thomcom_shell/bashrc"
    
    # Create necessary directories
    info "Creating required directories..."
    mkdir -p "$HOME/.bash_broadcasts"
    success "Broadcast directory created"
    
    # Handle work-specific configuration  
    # Use configurable secrets directory (defaults to .secrets for general use)
    SECRETS_DIR="${THOMCOM_SECRETS_DIR:-$HOME/.secrets}"
    if [[ ! -d "$SECRETS_DIR" ]]; then
        mkdir -p "$SECRETS_DIR"
        info "Created $SECRETS_DIR directory for work-specific configurations"
        
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
    
    # We do not change the user's default shell
    # bash configuration works with any default shell

    # Run tests to verify installation
    info "Running installation tests..."
    if "$SHELL_DIR/tests/test_suite.sh" >/dev/null 2>&1; then
        success "All tests passed"
    else
        warning "Some tests failed - installation may have issues"
    fi
    
    echo -e "\n${GREEN}🎉 Installation completed successfully!${NC}\n"
    echo "Starting bash with your new configuration..."
    echo
    echo "Documentation: $SHELL_DIR/README.md"
    echo "Support: https://github.com/thomcom/thomcom-shell/issues"
    echo
    
    # Source the configuration and start bash to demonstrate it works
    exec bash -c "source ~/.bashrc; exec bash"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    error "This script should not be run as root"
fi

# Run main function
main "$@"