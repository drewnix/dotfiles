# ============================================================================
# YAZI - Blazing Fast Terminal File Manager
# ============================================================================
# Homepage: https://yazi-rs.github.io/
# GitHub: https://github.com/sxyazi/yazi

# ============================================================================
# Shell Wrapper Function - CD on Exit
# ============================================================================
# This function allows yazi to change the shell's working directory when you quit
# Critical for seamless terminal integration

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# ============================================================================
# Yazi Aliases
# ============================================================================

# Quick yazi launch
alias yz='yazi'

# Open yazi in specific directories
alias yh='yazi ~'                    # Home directory
alias yc='yazi ~/.config'            # Config directory
alias yd='yazi ~/Downloads'          # Downloads
alias yp='yazi ~/Projects'           # Projects
alias yw='yazi ~/work'               # Work directory
alias yD='yazi ~/dotfiles'           # Dotfiles

# Yazi with specific options
alias ya='yazi --cwd-file'           # Launch with cwd file support
alias yv='yazi --chooser-file'       # Use as file chooser

# ============================================================================
# Plugin Management
# ============================================================================

# Install essential yazi plugins
alias yazi-setup='yazi-install-plugins'

# Update all yazi plugins
alias yazi-update='ya pkg upgrade'

# List installed yazi packages
alias yazi-list='ya pkg list'

# ============================================================================
# Helper Functions
# ============================================================================

# Install all recommended yazi plugins
function yazi-install-plugins() {
	echo "Installing yazi plugins..."

	# Essential official plugins
	ya pkg add yazi-rs/plugins:full-border
	ya pkg add yazi-rs/plugins:git
	ya pkg add yazi-rs/plugins:smart-enter

	# Tokyo Night theme
	ya pkg add BennyOe/tokyo-night

	# Navigation and search enhancements
	ya pkg add DreamMaoMao/easyjump.yazi
	ya pkg add lpnh/fr

	echo "✓ Yazi plugins installed successfully!"
	echo "Restart yazi to activate plugins."
}

# Quick file search with yazi and fzf
function yz-find() {
	local selected
	selected=$(fd --type f --hidden --exclude .git | fzf --preview 'bat --style=numbers --color=always {}')
	if [ -n "$selected" ]; then
		yazi "$selected"
	fi
}

# Open yazi in the current git repository root
function yz-git-root() {
	local git_root
	git_root=$(git rev-parse --show-toplevel 2>/dev/null)
	if [ -n "$git_root" ]; then
		yazi "$git_root"
	else
		echo "Not in a git repository"
		return 1
	fi
}

# Open yazi and cd to selected directory
function yz-cd() {
	local selected
	selected=$(fd --type d --hidden --exclude .git | fzf --preview 'ls -lah {}')
	if [ -n "$selected" ]; then
		cd "$selected" && yazi
	fi
}

# Quick navigation shortcuts using yazi
function yz-projects() {
	local project
	project=$(fd --type d --max-depth 2 . ~/Projects 2>/dev/null | fzf --preview 'ls -lah {}')
	if [ -n "$project" ]; then
		cd "$project" && yazi
	fi
}

# ============================================================================
# Integration with Other Tools
# ============================================================================

# Open yazi in the directory of the currently selected kubectl context
function yz-k8s-context() {
	local context
	context=$(kubectl config current-context 2>/dev/null)
	if [ -n "$context" ]; then
		echo "Current K8s context: $context"
		yazi ~/.kube
	else
		echo "No kubectl context found"
		return 1
	fi
}

# ============================================================================
# Configuration Management
# ============================================================================

# Edit yazi configuration files
alias yazi-config-edit='$EDITOR ~/.config/yazi/yazi.toml'
alias yazi-keymap-edit='$EDITOR ~/.config/yazi/keymap.toml'
alias yazi-theme-edit='$EDITOR ~/.config/yazi/theme.toml'
alias yazi-init-edit='$EDITOR ~/.config/yazi/init.lua'

# Reload yazi configuration (restart yazi)
alias yazi-reload='echo "Restart yazi to reload configuration"'

# Open yazi config directory
alias yazi-config='yazi ~/.config/yazi'

# ============================================================================
# Debugging and Troubleshooting
# ============================================================================

# Check yazi version and dependencies
function yazi-info() {
	echo "=== Yazi Information ==="
	command -v yazi >/dev/null && yazi --version || echo "yazi: not installed"
	echo ""
	echo "=== Dependencies ==="
	command -v ffmpeg >/dev/null && echo "✓ ffmpeg" || echo "✗ ffmpeg (for video thumbnails)"
	command -v 7z >/dev/null && echo "✓ 7z" || echo "✗ 7z (for archive previews)"
	command -v jq >/dev/null && echo "✓ jq" || echo "✗ jq (for JSON formatting)"
	command -v fd >/dev/null && echo "✓ fd" || echo "✗ fd (for fast file finding)"
	command -v rg >/dev/null && echo "✓ rg" || echo "✗ rg (for content search)"
	command -v fzf >/dev/null && echo "✓ fzf" || echo "✗ fzf (for fuzzy finding)"
	command -v bat >/dev/null && echo "✓ bat" || echo "✗ bat (for syntax highlighting)"
	command -v zoxide >/dev/null && echo "✓ zoxide" || echo "✗ zoxide (for smart jumping)"
	echo ""
	echo "=== Installed Plugins ==="
	ya pkg list 2>/dev/null || echo "No plugins installed or ya command not found"
}

# View yazi logs
alias yazi-log='tail -f ~/.local/state/yazi/yazi.log'

# Clear yazi cache
alias yazi-clear-cache='rm -rf ~/.cache/yazi/*'
