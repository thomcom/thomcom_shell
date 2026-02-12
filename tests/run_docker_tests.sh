#!/bin/bash
##############################################################################
# Docker Test Runner for thomcom_shell
# Handles docker installation and permission issues automatically
##############################################################################

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info() { echo -e "${BLUE}ℹ $1${NC}"; }
success() { echo -e "${GREEN}✓ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
error() { echo -e "${RED}✗ $1${NC}"; exit 1; }

echo -e "${BLUE}🐳 Docker Test Runner${NC}\n"

# Check if docker is installed
if ! command -v docker >/dev/null 2>&1; then
    warning "Docker not found - installing Docker in user mode (rootless)"

    # Install Docker using official script
    curl -fsSL https://get.docker.com/rootless | sh

    # Add to PATH for this session
    export PATH="$HOME/bin:$PATH"
    export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock

    if ! command -v docker >/dev/null 2>&1; then
        error "Docker installation failed"
    fi

    success "Docker installed successfully (rootless mode)"
fi

# Check if docker daemon is accessible
if ! docker info >/dev/null 2>&1; then
    warning "Docker daemon not accessible - checking permissions..."

    # Check if user is in docker group
    if ! groups | grep -q docker; then
        info "Adding user to docker group..."
        sudo usermod -aG docker "$USER"
        warning "User added to docker group - you may need to log out and back in"
        warning "For now, trying with sudo..."
        DOCKER_CMD="sudo docker"
    else
        # User is in group but permissions not active yet
        warning "Docker group membership detected but not active"
        warning "Using sudo for this session..."
        DOCKER_CMD="sudo docker"
    fi
else
    DOCKER_CMD="docker"
    success "Docker daemon accessible"
fi

# Build the test image
info "Building test image..."
# Build from parent directory with tests/Dockerfile.test as the Dockerfile
cd "$(dirname "$0")/.."
$DOCKER_CMD build -f tests/Dockerfile.test -t thomcom-shell:test .

success "Docker tests completed successfully!"
echo
info "To run the image interactively:"
echo "  $DOCKER_CMD run -it thomcom-shell:test"
