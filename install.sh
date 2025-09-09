#!/bin/bash
##############################################################################
# Thomcom Shell Installer
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
    echo -e "${BLUE}🚀 Thomcom Shell Installer${NC}\n"
    
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
    
    # Optional dependencies check
    info "Checking optional dependencies..."
    local missing_optional=()
    
    ! has_command jq && missing_optional+=("jq")
    ! has_command fd && ! has_command fdfind && missing_optional+=("fd-find")
    ! has_command rg && missing_optional+=("ripgrep")
    ! has_command fzf && missing_optional+=("fzf")
    
    if [[ ${#missing_optional[@]} -gt 0 ]]; then
        warning "Optional dependencies missing: ${missing_optional[*]}"
        warning "Some features may not work optimally. Install with:"
        warning "  Ubuntu/Debian: sudo apt install jq fd-find ripgrep fzf"
        warning "  macOS: brew install jq fd ripgrep fzf"
        echo
    else
        success "All optional dependencies found"
    fi
    
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
        info "Cloning Thomcom Shell repository..."
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
    if [[ ! -d "$HOME/.nvidia" ]]; then
        mkdir -p "$HOME/.nvidia"
        info "Created ~/.nvidia directory for work-specific configurations"
        
        cat > "$HOME/.nvidia/work.zsh" << 'EOF'
#!/bin/zsh
##############################################################################
# Work-Specific Configuration
# Add your company/work-specific settings here
##############################################################################

# Example: Internal network hosts
# export INTERNAL_HOST=10.0.0.1

# Example: Work-specific aliases  
# alias deploy='./scripts/deploy.sh'

# Example: Startup commands
# _work_startup() {
#     cd ~/work/projects
# }
EOF
        info "Created template work configuration at ~/.nvidia/work.zsh"
    fi
    
    # Run tests to verify installation
    info "Running installation tests..."
    if "$SHELL_DIR/test_modular_shell.sh" >/dev/null 2>&1; then
        success "All tests passed"
    else
        warning "Some tests failed - installation may have issues"
    fi
    
    echo -e "\n${GREEN}🎉 Installation completed successfully!${NC}\n"
    echo "Next steps:"
    echo "1. Start a new shell session or run: source ~/.zshrc"
    echo "2. Try the broadcast system: zbc \"echo Hello from all sessions!\""
    echo "3. Edit ~/.nvidia/work.zsh for work-specific configurations"
    echo "4. Run ~/.thomcom_shell/test_modular_shell.sh to verify everything works"
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