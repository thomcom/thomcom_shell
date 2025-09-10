#!/bin/bash
##############################################################################
# thomcom Shell Installer
# Installs and configures the modular ZSH shell system
##############################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SHELL_DIR="$HOME/.thomcom_shell"
REPO_URL="https://github.com/thomcom/thomcom-shell.git"  # Update with actual repo

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
    
    # Check for zsh
    if ! has_command zsh; then
        error "ZSH is required but not installed. Please install zsh first."
    fi
    success "ZSH found: $(zsh --version)"
    
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
        
        success "Micromamba installed successfully"
    else
        success "Micromamba already available"
        export MAMBA_EXE="$(command -v micromamba)"
        export MAMBA_ROOT_PREFIX="${MAMBA_ROOT_PREFIX:-$HOME/data/micromamba/}"
    fi
    
    # Create dev-tools environment with ALL our dependencies
    info "Creating dev-tools environment with all development dependencies..."
    
    # Check if dev-tools environment exists
    if ! "$MAMBA_EXE" env list | grep -q "dev-tools" 2>/dev/null; then
        info "Installing: python, nodejs, neovim, fzf, fd-find, ripgrep, jq into dev-tools environment..."
        "$MAMBA_EXE" create -n dev-tools -c conda-forge \
            python=3.11 \
            nodejs \
            neovim \
            fzf \
            fd-find \
            ripgrep \
            jq \
            -y || { warning "Some packages may not be available in conda-forge"; }
        
        success "dev-tools environment created with all development dependencies"
        
        # Install copilot for neovim
        info "Setting up neovim with copilot..."
        if [[ ! -d "$HOME/.config/nvim" ]]; then
            info "No existing nvim config found - will install mature thomcom/vim config later"
            info "Try this mature and minimal thomcom/vim config: https://github.com/thomcom/vim"
        else
            info "Existing nvim config detected - preserving your setup"
        fi
        
        # Install vim-plug for plugin management
        if [[ ! -f "$HOME/.local/share/nvim/site/autoload/plug.vim" ]]; then
            info "Installing vim-plug for neovim..."
            curl -fLo "$HOME/.local/share/nvim/site/autoload/plug.vim" --create-dirs \
                https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
            success "vim-plug installed"
        fi
        
    else
        success "dev-tools environment already exists"
        
        # Still check for neovim in existing environment
        info "Checking for neovim in existing dev-tools environment..."
        if ! "$MAMBA_EXE" list -n dev-tools neovim | grep -q neovim 2>/dev/null; then
            info "Adding neovim to existing dev-tools environment..."
            "$MAMBA_EXE" install -n dev-tools -c conda-forge neovim -y
            success "neovim added to dev-tools environment"
        fi
    fi
    
    info "🏗️ Architecture: OS → APT/Brew (minimal) → Micromamba → dev-tools → project envs"
    success "Development environment isolation complete!"
    
    # Backup existing .zshrc
    if [[ -f "$HOME/.zshrc" && ! -L "$HOME/.zshrc" ]]; then
        info "Backing up existing .zshrc to .zshrc.backup"
        cp "$HOME/.zshrc" "$HOME/.zshrc.backup"
        success "Backup created"
    fi
    
    # Clone or update repository
    if [[ -d "$SHELL_DIR" ]]; then
        info "Updating existing installation..."
        cd "$SHELL_DIR"
        git pull
        success "Updated from repository"
    else
        info "Cloning thomcom Shell repository..."
        git clone "$REPO_URL" "$SHELL_DIR"
        success "Repository cloned"
    fi
    
    # Create symlink
    info "Setting up .zshrc symlink..."
    rm -f "$HOME/.zshrc"  # Remove existing file or symlink
    ln -s "$SHELL_DIR/zshrc" "$HOME/.zshrc"
    success "Symlink created: ~/.zshrc -> ~/.thomcom_shell/zshrc"
    
    # Create necessary directories
    info "Creating required directories..."
    mkdir -p "$HOME/.zsh_broadcasts"
    success "Broadcast directory created"
    
    # Handle work-specific configuration  
    # Use configurable secrets directory (defaults to .secrets for general use)
    SECRETS_DIR="${THOMCOM_SECRETS_DIR:-$HOME/.secrets}"
    if [[ ! -d "$SECRETS_DIR" ]]; then
        mkdir -p "$SECRETS_DIR"
        info "Created $SECRETS_DIR directory for work-specific configurations"
        
        cat > "$SECRETS_DIR/work.zsh" << 'EOF'
#!/bin/zsh
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
        info "Created template work configuration at $SECRETS_DIR/work.zsh"
    fi
    
    # Run tests to verify installation
    info "Running installation tests..."
    if "$SHELL_DIR/tests/test_suite.sh" >/dev/null 2>&1; then
        success "All tests passed"
    else
        warning "Some tests failed - installation may have issues"
    fi
    
    echo -e "\n${GREEN}🎉 Installation completed successfully!${NC}\n"
    echo "Next steps:"
    echo "1. Start a new shell session or run: source ~/.zshrc"
    echo "2. Try the broadcast system: zbc \"echo Hello from all sessions!\""
    echo "3. Edit $SECRETS_DIR/work.zsh for work-specific configurations"
    echo "4. Run ./tests/test_suite.sh to verify everything works"
    echo
    echo "Documentation: $SHELL_DIR/README.md"
    echo "Support: https://github.com/thomcom/thomcom-shell/issues"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    error "This script should not be run as root"
fi

# Run main function
main "$@"