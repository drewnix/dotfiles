#!/usr/bin/env bash
# ============================================================================
# Yazi Plugin Installation Script
# ============================================================================
# Installs essential yazi plugins and flavors using the ya package manager
#
# Usage:
#   ./install-plugins.sh           # Install all recommended plugins
#   ./install-plugins.sh --minimal # Install only essential plugins

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================================
# Helper Functions
# ============================================================================

print_header() {
	echo -e "${BLUE}===================================${NC}"
	echo -e "${BLUE}$1${NC}"
	echo -e "${BLUE}===================================${NC}"
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

command_exists() {
	command -v "$1" >/dev/null 2>&1
}

install_plugin() {
	local plugin=$1
	local description=$2

	echo -e "\n${BLUE}Installing:${NC} $description"

	# Try to add the plugin, capture output
	local output
	if output=$(ya pkg add "$plugin" 2>&1); then
		print_success "$description installed"
	elif echo "$output" | grep -q "already exists"; then
		print_success "$description already installed"
	else
		print_error "Failed to install $description"
		print_error "$output"
		return 1
	fi
}

# ============================================================================
# Pre-flight Checks
# ============================================================================

print_header "Yazi Plugin Installation"

# Check if yazi is installed
if ! command_exists yazi; then
	print_error "yazi is not installed. Please install yazi first."
	exit 1
fi

# Check if ya command is available
if ! command_exists ya; then
	print_error "ya package manager not found. Please ensure yazi is properly installed."
	exit 1
fi

print_info "Yazi version: $(yazi --version)"
echo ""

# ============================================================================
# Installation Mode
# ============================================================================

MINIMAL=false
if [[ "$1" == "--minimal" ]]; then
	MINIMAL=true
	print_info "Running in minimal mode (essential plugins only)"
	echo ""
fi

# ============================================================================
# Essential Plugins (Always Installed)
# ============================================================================

print_header "Installing Essential Plugins"

# Full border - Enhanced visual clarity
install_plugin "yazi-rs/plugins:full-border" "Full Border (visual structure)"

# Git integration - File status in linemode
install_plugin "yazi-rs/plugins:git" "Git Integration (file status)"

# Smart enter - Open files or enter directories
install_plugin "yazi-rs/plugins:smart-enter" "Smart Enter (streamlined navigation)"

# Tokyo Night theme
install_plugin "BennyOe/tokyo-night" "Tokyo Night Theme"

print_success "Essential plugins installed!"

# ============================================================================
# Optional Plugins (Skipped in Minimal Mode)
# ============================================================================

if [[ "$MINIMAL" == false ]]; then
	echo ""
	print_header "Installing Optional Plugins"

	# Easyjump - Hop-style navigation
	# Note: Package name format issue - install manually if needed: ya pkg add DreamMaoMao/yazi-easyjump
	# install_plugin "DreamMaoMao/easyjump.yazi" "Easyjump (hop-style navigation)"

	# Fr - Ripgrep integration with fzf
	install_plugin "lpnh/fr" "Fr (ripgrep + fzf search)"

	# Chmod - Quick permission changes
	install_plugin "yazi-rs/plugins:chmod" "Chmod (permission management)"

	# Max preview - Better preview toggling (toggle-pane is already in essentials)
	# install_plugin "yazi-rs/plugins:max-preview" "Max Preview (preview toggling)"

	print_success "Optional plugins installed!"
else
	print_info "Skipping optional plugins (use without --minimal flag to install)"
fi

# ============================================================================
# Post-Installation
# ============================================================================

echo ""
print_header "Installation Complete"

echo ""
print_info "Installed packages:"
ya pkg list

echo ""
print_success "All plugins installed successfully!"
echo ""
print_info "Next steps:"
echo "  1. Restart yazi to activate plugins"
echo "  2. Run 'yazi' or 'y' to launch"
echo "  3. Press '?' in yazi to see all keybindings"
echo "  4. Use 'ya pkg upgrade' to update plugins"
echo ""
print_info "Configuration location: ~/.config/yazi/"
print_info "Plugin location: ~/.config/yazi/packages/"
echo ""

# ============================================================================
# Dependency Check
# ============================================================================

print_header "Checking Optional Dependencies"

echo ""
print_info "These tools enhance yazi's functionality:"
echo ""

command_exists ffmpeg && print_success "ffmpeg (video thumbnails)" || print_warning "ffmpeg not found (optional: video thumbnails)"
command_exists 7z && print_success "7z (archive previews)" || print_warning "7z not found (optional: archive previews)"
command_exists jq && print_success "jq (JSON formatting)" || print_warning "jq not found (optional: JSON formatting)"
command_exists fd && print_success "fd (fast file finding)" || print_warning "fd not found (recommended: file search)"
command_exists rg && print_success "rg (content search)" || print_warning "rg not found (recommended: content search)"
command_exists fzf && print_success "fzf (fuzzy finding)" || print_warning "fzf not found (recommended: fuzzy search)"
command_exists bat && print_success "bat (syntax highlighting)" || print_warning "bat not found (recommended: previews)"
command_exists zoxide && print_success "zoxide (smart jumping)" || print_warning "zoxide not found (optional: smart cd)"

echo ""
print_info "Install missing dependencies with your package manager or run bootstrap.sh"
echo ""

exit 0
