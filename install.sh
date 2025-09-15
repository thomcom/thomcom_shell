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
    
    # Check for zsh and install if missing
    if ! has_command zsh; then
        warning "ZSH not found - attempting to install..."
        
        if has_command apt-get; then
            sudo apt-get update && sudo apt-get install -y zsh
        elif has_command yum; then
            sudo yum install -y zsh
        elif has_command pacman; then
            sudo pacman -S --noconfirm zsh
        elif has_command brew; then
            brew install zsh
        else
            error "Could not determine package manager. Please install zsh manually and re-run."
        fi
        
        if ! has_command zsh; then
            error "ZSH installation failed. Please install zsh manually and re-run."
        fi
        success "ZSH installed successfully"
    else
        success "ZSH found: $(zsh --version)"
    fi
    
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
        export MAMBA_EXE="$(command -v micromamba)"
        export MAMBA_ROOT_PREFIX="${MAMBA_ROOT_PREFIX:-$HOME/data/micromamba/}"
    fi
    
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
    
    # Create dev-tools environment with ALL our dependencies
    info "Creating dev-tools environment with all development dependencies..."
    
    # Check if dev-tools environment exists (with proper error handling)
    if ! "$MAMBA_EXE" env list 2>/dev/null | grep -q "dev-tools"; then
        info "Installing: python, nodejs, neovim, fzf, fd-find, ripgrep, jq into dev-tools environment..."
        
        if "$MAMBA_EXE" create -n dev-tools -c conda-forge \
            python=3.11 \
            nodejs \
            neovim \
            fzf \
            fd-find \
            ripgrep \
            jq \
            -y; then
            success "dev-tools environment created with all development dependencies"
        else
            error "Failed to create dev-tools environment. Check internet connection and try again."
        fi
        
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
    
    # Set ZSH as default shell if not already
    if [[ "$SHELL" != *"zsh"* ]]; then
        info "Setting ZSH as default shell..."
        if grep -q "$(which zsh)" /etc/shells; then
            # Use timeout to prevent hanging, and make it non-interactive
            if timeout 10s chsh -s "$(which zsh)" 2>/dev/null; then
                success "ZSH set as default shell (takes effect on next login)"
            else
                warning "Could not change default shell automatically"
                info "To set manually, run: chsh -s \$(which zsh)"
            fi
        else
            warning "ZSH not in /etc/shells - please add it manually:"
            info "Run: echo \$(which zsh) | sudo tee -a /etc/shells"
        fi
    fi
    
    # Run tests to verify installation
    info "Running installation tests..."
    if "$SHELL_DIR/tests/test_suite.sh" >/dev/null 2>&1; then
        success "All tests passed"
    else
        warning "Some tests failed - installation may have issues"
    fi
    
    echo -e "\n${GREEN}🎉 Installation completed successfully!${NC}\n"
    echo "Starting ZSH with your new configuration..."
    echo
    echo "Documentation: $SHELL_DIR/README.md"
    echo "Support: https://github.com/thomcom/thomcom-shell/issues"
    echo
    
    # Source the configuration and start ZSH to demonstrate it works
    exec zsh -c "source ~/.zshrc; exec zsh"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    error "This script should not be run as root"
fi

# Run main function
main "$@"