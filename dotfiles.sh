#!/usr/bin/env bash

# ╔══════════════════════════════════════════════════════════════╗
# ║ Dotfiles Stow Installer                                      ║
# ╚══════════════════════════════════════════════════════════════╝
#
# This script uses GNU Stow to symlink dotfiles to your home directory.
# It checks for conflicts before creating any symlinks.
#
# Usage: ./dotfiles.sh [package1 package2 ...]
#        ./dotfiles.sh --all        # Install all packages
#        ./dotfiles.sh zsh git      # Install specific packages

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Available packages
ALL_PACKAGES=(
    zsh
    git
    tmux
    vim
    ranger
    aws
    bash
    fish
    starship
    mise
    claude
)

# Default packages to install if no arguments provided
DEFAULT_PACKAGES=(
    zsh
    git
    tmux
    vim
    ranger
    starship
    mise
    claude
)

info() {
    echo -e "${GREEN}==>${NC} $1"
}

warning() {
    echo -e "${YELLOW}==>${NC} $1"
}

error() {
    echo -e "${RED}==>${NC} $1"
}

# Check if 'stow' command exists
if ! command -v stow &> /dev/null; then
    error "GNU Stow is required but not found"
    echo "Please install GNU Stow:"
    echo "  - macOS: brew install stow"
    echo "  - Ubuntu/Debian: sudo apt install stow"
    echo "  - Fedora: sudo dnf install stow"
    exit 1
fi

# Determine which packages to install
PACKAGES=()

if [ $# -eq 0 ]; then
    # No arguments - use default packages
    PACKAGES=("${DEFAULT_PACKAGES[@]}")
    info "No packages specified, using defaults: ${DEFAULT_PACKAGES[*]}"
elif [ "$1" == "--all" ]; then
    # Install all packages
    PACKAGES=("${ALL_PACKAGES[@]}")
    info "Installing all packages: ${ALL_PACKAGES[*]}"
else
    # Use specified packages
    PACKAGES=("$@")
    info "Installing specified packages: ${PACKAGES[*]}"
fi

# Get to dotfiles directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

echo ""
info "Dotfiles directory: $DOTFILES_DIR"
echo ""

# Process each package
SUCCESS_COUNT=0
SKIP_COUNT=0
CONFLICT_COUNT=0

for PKG in "${PACKAGES[@]}"; do
    # Check if package directory exists
    if [ ! -d "$PKG" ]; then
        warning "Package directory '$PKG' not found, skipping..."
        ((SKIP_COUNT++))
        continue
    fi

    info "Processing package: $PKG"

    # Check for conflicts using stow's dry-run
    # Filter out the harmless simulation mode warning
    CONFLICTS=$(stow --no --verbose=1 "$PKG" 2>&1 | grep "WARNING\|ERROR" | grep -v "simulation mode" || true)

    if [ -n "$CONFLICTS" ]; then
        warning "Conflicts found with package '$PKG':"
        echo "$CONFLICTS" | sed 's/^/  /'
        warning "Skipping $PKG (resolve conflicts manually)"
        ((CONFLICT_COUNT++))
        echo ""
        continue
    fi

    # No conflicts, proceed with stowing
    if stow --restow --no-folding --verbose=1 "$PKG" 2>&1 | grep -v "BUG in find_stowed_path"; then
        info "✓ Successfully stowed: $PKG"
        ((SUCCESS_COUNT++))
    else
        warning "Failed to stow: $PKG"
        ((SKIP_COUNT++))
    fi

    echo ""
done

# Summary
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                     Installation Summary                     ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "  Successfully installed: $SUCCESS_COUNT"
echo "  Skipped (conflicts):    $CONFLICT_COUNT"
echo "  Skipped (other):        $SKIP_COUNT"
echo ""

if [ $SUCCESS_COUNT -gt 0 ]; then
    info "Dotfiles have been successfully linked!"
    echo ""
    echo "Next steps:"
    echo "  1. Restart your terminal or run: source ~/.zshrc"
    echo "  2. Review any conflict warnings above"
    echo "  3. Customize configs in ~/.config/ as needed"
    echo ""
fi

if [ $CONFLICT_COUNT -gt 0 ]; then
    warning "Some packages had conflicts. To resolve:"
    echo "  1. Backup existing files manually"
    echo "  2. Remove conflicting files"
    echo "  3. Run this script again"
    echo ""
fi

exit 0
