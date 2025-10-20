#!/bin/bash
# =============================================================================
# LSP Server Installation Script for Vim
# =============================================================================
# Optional installation of global LSP servers and tools for IDE-like experience
# Run this if you want full language support in Vim
#
# Usage:
#   ./install-lsp-servers.sh          # Install all available
#   ./install-lsp-servers.sh --help   # Show this help
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
command_exists() {
    command -v "$1" &> /dev/null
}

print_header() {
    echo -e "${BLUE}===================================================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}===================================================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Show help
if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    cat <<EOF
LSP Server Installation Script for Vim

This script installs global LSP servers and development tools for use with Vim.
It detects available package managers and only installs what's possible.

Installation Tiers:
  1. System tools (fzf, ripgrep, shellcheck) - Required for fuzzy finding
  2. Node.js LSP servers - For Python, TypeScript, YAML, Bash
  3. Go tools - For Go development
  4. Rust components - For Rust development

Usage:
  ./install-lsp-servers.sh          Install all available tools
  ./install-lsp-servers.sh --help   Show this help

Note: Project-specific tools (prettier, eslint, black, isort) should be
      installed per-project via package.json or requirements.txt

Installation Locations:
  - Node.js packages: ~/.local/bin (no sudo required)
  - Python packages: ~/.local/bin (installed with --user)
  - Go tools: ~/go/bin (GOPATH/bin)
  - Rust tools: ~/.rustup (rustup components)

Ensure ~/.local/bin and ~/go/bin are in your PATH!

EOF
    exit 0
fi

# Main installation
print_header "Vim LSP Server Installation"

echo ""
print_info "This script will install global LSP servers and development tools."
print_info "It will skip tools that can't be installed on your system."
echo ""

# Track what was installed
INSTALLED_COUNT=0
SKIPPED_COUNT=0

# =============================================================================
# System Tools (fzf, ripgrep, shellcheck)
# =============================================================================
print_header "System Tools (fzf, ripgrep, shellcheck)"

if command_exists dnf; then
    echo "Detected Fedora/RHEL - using dnf..."
    if ! command_exists fzf || ! command_exists rg || ! command_exists shellcheck; then
        sudo dnf install -y fzf ripgrep ShellCheck
        print_success "System tools installed via dnf"
        ((INSTALLED_COUNT+=3))
    else
        print_warning "System tools already installed, skipping"
        ((SKIPPED_COUNT+=3))
    fi
elif command_exists brew; then
    echo "Detected macOS - using Homebrew..."
    BREW_TOOLS=""
    ! command_exists fzf && BREW_TOOLS="$BREW_TOOLS fzf"
    ! command_exists rg && BREW_TOOLS="$BREW_TOOLS ripgrep"
    ! command_exists shellcheck && BREW_TOOLS="$BREW_TOOLS shellcheck"

    if [[ -n "$BREW_TOOLS" ]]; then
        brew install $BREW_TOOLS
        print_success "System tools installed via Homebrew"
        ((INSTALLED_COUNT+=3))
    else
        print_warning "System tools already installed, skipping"
        ((SKIPPED_COUNT+=3))
    fi
elif command_exists apt; then
    echo "Detected Debian/Ubuntu - using apt..."
    if ! command_exists fzf || ! command_exists rg || ! command_exists shellcheck; then
        sudo apt update
        sudo apt install -y fzf ripgrep shellcheck
        print_success "System tools installed via apt"
        ((INSTALLED_COUNT+=3))
    else
        print_warning "System tools already installed, skipping"
        ((SKIPPED_COUNT+=3))
    fi
elif command_exists pacman; then
    echo "Detected Arch Linux - using pacman..."
    if ! command_exists fzf || ! command_exists rg || ! command_exists shellcheck; then
        sudo pacman -S --noconfirm fzf ripgrep shellcheck
        print_success "System tools installed via pacman"
        ((INSTALLED_COUNT+=3))
    else
        print_warning "System tools already installed, skipping"
        ((SKIPPED_COUNT+=3))
    fi
else
    print_error "No supported package manager found (dnf, brew, apt, pacman)"
    print_info "Please install fzf, ripgrep, and shellcheck manually"
    ((SKIPPED_COUNT+=3))
fi

echo ""

# =============================================================================
# Node.js-based LSP Servers
# =============================================================================
print_header "Node.js LSP Servers"

if command_exists npm; then
    NODE_VERSION=$(node --version 2>/dev/null || echo "unknown")
    print_info "Node.js detected: $NODE_VERSION"

    # Check what's already installed globally (check both system and user locations)
    GLOBALLY_INSTALLED=$(npm list -g --depth=0 2>/dev/null || echo "")
    USER_INSTALLED=$(npm list -g --prefix ~/.local --depth=0 2>/dev/null || echo "")

    NPM_PACKAGES=""

    # pyright (Python LSP)
    if echo "$GLOBALLY_INSTALLED $USER_INSTALLED" | grep -q "pyright@"; then
        print_warning "pyright already installed, skipping"
        ((SKIPPED_COUNT++))
    else
        NPM_PACKAGES="$NPM_PACKAGES pyright"
    fi

    # typescript-language-server
    if echo "$GLOBALLY_INSTALLED $USER_INSTALLED" | grep -q "typescript-language-server@"; then
        print_warning "typescript-language-server already installed, skipping"
        ((SKIPPED_COUNT++))
    else
        NPM_PACKAGES="$NPM_PACKAGES typescript typescript-language-server"
    fi

    # bash-language-server
    if echo "$GLOBALLY_INSTALLED $USER_INSTALLED" | grep -q "bash-language-server@"; then
        print_warning "bash-language-server already installed, skipping"
        ((SKIPPED_COUNT++))
    else
        NPM_PACKAGES="$NPM_PACKAGES bash-language-server"
    fi

    # yaml-language-server
    if echo "$GLOBALLY_INSTALLED $USER_INSTALLED" | grep -q "yaml-language-server@"; then
        print_warning "yaml-language-server already installed, skipping"
        ((SKIPPED_COUNT++))
    else
        NPM_PACKAGES="$NPM_PACKAGES yaml-language-server"
    fi

    # Install if there's anything to install
    if [[ -n "$NPM_PACKAGES" ]]; then
        print_info "Installing: $NPM_PACKAGES"
        print_info "Installing to ~/.local (user directory, no sudo required)"

        # Install to user directory to avoid permission issues
        npm install -g --prefix ~/.local $NPM_PACKAGES

        # Check if ~/.local/bin is in PATH
        if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
            print_warning "~/.local/bin is not in your PATH"
            print_info "Add this to your ~/.zshrc or ~/.bashrc:"
            print_info "  export PATH=\"\$HOME/.local/bin:\$PATH\""
        fi

        print_success "Node.js LSP servers installed to ~/.local"
        ((INSTALLED_COUNT+=4))
    else
        print_warning "All Node.js LSP servers already installed"
    fi
else
    print_warning "Node.js/npm not found - skipping Node.js LSP servers"
    print_info "Install Node.js via mise or system package manager to enable:"
    print_info "  - pyright (Python LSP)"
    print_info "  - typescript-language-server (TypeScript/JavaScript LSP)"
    print_info "  - bash-language-server (Shell script LSP)"
    print_info "  - yaml-language-server (YAML/Kubernetes LSP)"
    ((SKIPPED_COUNT+=4))
fi

echo ""

# =============================================================================
# Python formatters and linters
# =============================================================================
print_header "Python Tools (Global)"

if command_exists pip3 || command_exists pip; then
    PIP_CMD="pip3"
    command_exists pip3 || PIP_CMD="pip"

    PYTHON_VERSION=$($PIP_CMD --version | grep -oP 'python \K[0-9.]+' || echo "unknown")
    print_info "Python detected: $PYTHON_VERSION"
    print_info "Installing global formatters (black, isort, flake8, mypy)"

    $PIP_CMD install --user --upgrade black isort flake8 mypy
    print_success "Python tools installed"
    print_info "Note: Consider installing per-project in virtualenvs"
    ((INSTALLED_COUNT+=4))
else
    print_warning "Python/pip not found - skipping Python tools"
    print_info "Install Python via mise or system package manager"
    ((SKIPPED_COUNT+=4))
fi

echo ""

# =============================================================================
# Go tools
# =============================================================================
print_header "Go Tools"

if command_exists go; then
    GO_VERSION=$(go version | awk '{print $3}')
    print_info "Go detected: $GO_VERSION"

    # gopls
    if command_exists gopls; then
        print_warning "gopls already installed, skipping"
        ((SKIPPED_COUNT++))
    else
        print_info "Installing gopls..."
        go install golang.org/x/tools/gopls@latest
        print_success "gopls installed"
        ((INSTALLED_COUNT++))
    fi

    # golint
    if command_exists golint; then
        print_warning "golint already installed, skipping"
        ((SKIPPED_COUNT++))
    else
        print_info "Installing golint..."
        go install golang.org/x/lint/golint@latest
        print_success "golint installed"
        ((INSTALLED_COUNT++))
    fi

    print_info "Ensure \$GOPATH/bin is in your PATH (usually ~/go/bin)"
else
    print_warning "Go not found - skipping Go tools"
    print_info "Install Go via mise or system package manager to enable:"
    print_info "  - gopls (Go LSP server)"
    print_info "  - golint (Go linter)"
    ((SKIPPED_COUNT+=2))
fi

echo ""

# =============================================================================
# Rust components
# =============================================================================
print_header "Rust Components"

if command_exists rustup; then
    RUST_VERSION=$(rustc --version 2>/dev/null || echo "unknown")
    print_info "Rust detected: $RUST_VERSION"

    # Check if components are already installed
    RUSTUP_COMPONENTS=$(rustup component list --installed 2>/dev/null || echo "")

    RUST_COMPONENTS=""

    if echo "$RUSTUP_COMPONENTS" | grep -q "rustfmt"; then
        print_warning "rustfmt already installed, skipping"
        ((SKIPPED_COUNT++))
    else
        RUST_COMPONENTS="$RUST_COMPONENTS rustfmt"
    fi

    if echo "$RUSTUP_COMPONENTS" | grep -q "rust-analyzer"; then
        print_warning "rust-analyzer already installed, skipping"
        ((SKIPPED_COUNT++))
    else
        RUST_COMPONENTS="$RUST_COMPONENTS rust-analyzer"
    fi

    if [[ -n "$RUST_COMPONENTS" ]]; then
        print_info "Installing: $RUST_COMPONENTS"
        rustup component add $RUST_COMPONENTS
        print_success "Rust components installed"
        ((INSTALLED_COUNT+=2))
    else
        print_warning "All Rust components already installed"
    fi
else
    print_warning "Rust/rustup not found - skipping Rust components"
    print_info "Install Rust via mise or rustup to enable:"
    print_info "  - rustfmt (Rust formatter)"
    print_info "  - rust-analyzer (Rust LSP server)"
    ((SKIPPED_COUNT+=2))
fi

echo ""

# =============================================================================
# Summary
# =============================================================================
print_header "Installation Summary"

echo ""
print_success "Installed: $INSTALLED_COUNT tools/components"
print_warning "Skipped: $SKIPPED_COUNT tools/components (already installed or unavailable)"
echo ""

print_info "Next steps:"
echo "  1. Open Vim and run :PlugInstall to install plugins"
echo "  2. Restart Vim to load everything"
echo "  3. Check :ALEInfo to verify LSP servers are detected"
echo ""

print_info "Project-specific tools:"
echo "  - JavaScript/TypeScript: Add prettier, eslint to package.json devDependencies"
echo "  - Python: Create virtualenv and install black, isort, flake8 per-project"
echo "  - Go: Tools auto-discovered from GOPATH"
echo "  - Rust: Tools from rustup work globally"
echo ""

print_success "Setup complete! Happy Vimming! 🎉"
