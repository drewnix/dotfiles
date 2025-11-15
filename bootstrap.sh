#!/usr/bin/env bash

# ╔══════════════════════════════════════════════════════════════╗
# ║ Drewnix Dotfiles Bootstrap Script                            ║
# ╚══════════════════════════════════════════════════════════════╝
#
# This script automates the installation of essential tools for
# cloud-native development and DevOps workflows.
#
# Usage: ./bootstrap.sh [options]
#
# Options:
#   --minimal     Install only essential tools
#   --full        Install everything (default)
#   --help        Show this help message

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ╔══════════════════════════════════════════════════════════════╗
# ║ Package Lists - Declarative Configuration                    ║
# ╚══════════════════════════════════════════════════════════════╝

# Core essentials - always installed
CORE_PACKAGES="stow git zsh curl wget"

# Build tools - needed for compiling from source
BUILD_PACKAGES="build-essential"

# Modern CLI tools - enhanced alternatives to classic tools
MODERN_CLI_PACKAGES="fzf ripgrep fd bat eza yazi zoxide tmux"

# Media processing tools - for yazi file previews
MEDIA_PACKAGES="jq ffmpeg p7zip poppler imagemagick chafa ueberzug"

# ╔══════════════════════════════════════════════════════════════╗
# ║ Helper Functions                                             ║
# ╚══════════════════════════════════════════════════════════════╝

# Get platform-specific package name
# Maps canonical package names to platform-specific names
# Compatible with bash 3.2+ (no associative arrays)
get_pkg_name() {
    local canonical=$1
    local pkg_name=""

    # Map package names based on canonical name and package manager
    # Format: canonical name -> brew apt dnf pacman
    case "$canonical" in
        fd)
            case $PKG_MANAGER in
                brew) pkg_name="fd" ;;
                apt) pkg_name="fd-find" ;;
                dnf) pkg_name="fd-find" ;;
                pacman) pkg_name="fd" ;;
            esac
            ;;
        p7zip)
            case $PKG_MANAGER in
                brew) pkg_name="p7zip" ;;
                apt) pkg_name="p7zip-full" ;;
                dnf) pkg_name="p7zip" ;;
                pacman) pkg_name="p7zip" ;;
            esac
            ;;
        poppler)
            case $PKG_MANAGER in
                brew) pkg_name="poppler" ;;
                apt) pkg_name="poppler-utils" ;;
                dnf) pkg_name="poppler-utils" ;;
                pacman) pkg_name="poppler" ;;
            esac
            ;;
        imagemagick)
            case $PKG_MANAGER in
                brew) pkg_name="imagemagick" ;;
                apt) pkg_name="imagemagick" ;;
                dnf) pkg_name="ImageMagick" ;;
                pacman) pkg_name="imagemagick" ;;
            esac
            ;;
        ueberzug)
            case $PKG_MANAGER in
                brew) pkg_name="ueberzugpp" ;;
                apt) pkg_name="-" ;;
                dnf) pkg_name="ueberzugpp" ;;
                pacman) pkg_name="ueberzug" ;;
            esac
            ;;
        build-essential)
            case $PKG_MANAGER in
                brew) pkg_name="-" ;;
                apt) pkg_name="build-essential" ;;
                dnf) pkg_name="-" ;;
                pacman) pkg_name="-" ;;
            esac
            ;;
        *)
            # No mapping, use canonical name
            pkg_name="$canonical"
            ;;
    esac

    echo "$pkg_name"
}

# Install a list of packages (space-separated)
install_package_list() {
    local packages=$1
    for pkg in $packages; do
        local pkg_name=$(get_pkg_name "$pkg")
        install_pkg "$pkg_name" "$pkg"
    done
}

# Try package manager first, fall back to alternative if needed
install_with_fallback() {
    local binary=$1
    local pkg_name=$2
    local fallback_cmd=$3

    if command_exists "$binary"; then
        success "$binary already installed"
        return 0
    fi

    # Try package manager first
    if install_pkg "$pkg_name" "$binary" 2>/dev/null; then
        return 0
    fi

    # Package manager failed or unavailable, use fallback
    info "Installing $binary using fallback method..."
    eval "$fallback_cmd"
}

# Install ZSH plugin from GitHub
install_zsh_plugin() {
    local name=$1
    local repo=$2

    if [ -d "$HOME/.zsh/$name" ]; then
        success "$name already installed"
        return 0
    fi

    info "Installing $name..."
    mkdir -p "$HOME/.zsh"
    git clone "$repo" "$HOME/.zsh/$name" && success "$name installed"
}

info() {
    echo -e "${BLUE}==>${NC} $1"
}

success() {
    echo -e "${GREEN}==>${NC} $1"
}

warning() {
    echo -e "${YELLOW}==>${NC} $1"
}

error() {
    echo -e "${RED}==>${NC} $1"
}

command_exists() {
    command -v "$1" &> /dev/null
}

# Install binary from GitHub releases
github_install() {
    local repo=$1           # e.g., "stern/stern"
    local binary=$2         # e.g., "stern"
    local archive=$3        # e.g., "stern_{VERSION}_{OS}_{ARCH}.tar.gz"

    if command_exists "$binary"; then
        success "$binary already installed"
        return 0
    fi

    info "Installing $binary from GitHub ($repo)..."

    # Get latest release version
    local version=$(curl -s "https://api.github.com/repos/$repo/releases/latest" | grep tag_name | cut -d '"' -f 4)

    if [[ -z "$version" ]]; then
        error "Failed to fetch latest release version for $repo"
        return 1
    fi

    # Detect OS and architecture
    local os_name="linux"
    local arch_name="amd64"

    if [[ "$OSTYPE" == "darwin"* ]]; then
        os_name="darwin"
        # Detect Mac architecture
        if [[ $(uname -m) == "arm64" ]]; then
            arch_name="arm64"
        else
            arch_name="amd64"
        fi
    else
        # Linux
        if [[ $(uname -m) == "aarch64" ]] || [[ $(uname -m) == "arm64" ]]; then
            arch_name="arm64"
        fi
    fi

    # Build download URL (replace placeholders)
    local download_file="${archive/\{VERSION\}/${version#v}}"
    download_file="${download_file/\{OS\}/${os_name}}"
    download_file="${download_file/\{ARCH\}/${arch_name}}"
    local download_url="https://github.com/$repo/releases/download/${version}/${download_file}"

    # Create temporary directory
    local tmp_dir=$(mktemp -d)
    cd "$tmp_dir"

    # Download and extract
    info "Downloading from $download_url"
    if curl -L "$download_url" -o download_archive; then
        # Extract based on file type
        if [[ "$download_file" == *.tar.gz ]]; then
            tar xzf download_archive
        elif [[ "$download_file" == *.zip ]]; then
            unzip -q download_archive
        else
            # Assume it's a raw binary
            mv download_archive "$binary"
        fi

        # Install binary
        chmod +x "$binary"
        sudo mv "$binary" /usr/local/bin/

        cd - > /dev/null
        rm -rf "$tmp_dir"

        if command_exists "$binary"; then
            success "$binary installed successfully"
            return 0
        fi
    fi

    cd - > /dev/null
    rm -rf "$tmp_dir"
    error "Failed to install $binary"
    return 1
}

# ╔══════════════════════════════════════════════════════════════╗
# ║ Detect OS and Package Manager                                ║
# ╚══════════════════════════════════════════════════════════════╝

detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            OS=$ID
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    else
        error "Unsupported operating system: $OSTYPE"
        exit 1
    fi
    info "Detected OS: $OS"
}

install_package_manager() {
    if [[ "$OS" == "macos" ]]; then
        if ! command_exists brew; then
            info "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            success "Homebrew installed"
        else
            success "Homebrew already installed"
        fi
        PKG_MANAGER="brew"
    elif [[ "$OS" == "ubuntu" ]] || [[ "$OS" == "debian" ]]; then
        PKG_MANAGER="apt"
        info "Updating package list..."
        sudo apt update -qq
    elif [[ "$OS" == "fedora" ]] || [[ "$OS" == "rhel" ]] || [[ "$OS" == "centos" ]]; then
        PKG_MANAGER="dnf"
    elif [[ "$OS" == "arch" ]]; then
        PKG_MANAGER="pacman"
    else
        warning "Unknown package manager, some installations may fail"
        PKG_MANAGER="unknown"
    fi
}

install_pkg() {
    local pkg=$1
    local name=${2:-$pkg}

    # Skip if package is marked as unavailable on this platform
    if [[ "$pkg" == "-" ]]; then
        return 0
    fi

    if command_exists "$pkg"; then
        success "$name already installed"
        return 0
    fi

    info "Installing $name..."

    case $PKG_MANAGER in
        brew)
            brew install "$pkg" || warning "Failed to install $name"
            ;;
        apt)
            sudo apt install -y "$pkg" || warning "Failed to install $name"
            ;;
        dnf)
            sudo dnf install -y "$pkg" || warning "Failed to install $name"
            ;;
        pacman)
            sudo pacman -S --noconfirm "$pkg" || warning "Failed to install $name"
            ;;
        *)
            warning "Cannot install $name - unknown package manager"
            return 1
            ;;
    esac

    if command_exists "$pkg"; then
        success "$name installed successfully"
    fi
}

# ╔══════════════════════════════════════════════════════════════╗
# ║ Essential Tools Installation                                 ║
# ╚══════════════════════════════════════════════════════════════╝

install_essentials() {
    info "Installing essential tools..."

    # Core packages
    install_package_list "$CORE_PACKAGES"

    # Build tools
    install_package_list "$BUILD_PACKAGES"

    # Modern CLI tools
    install_package_list "$MODERN_CLI_PACKAGES"

    # Media processing tools
    install_package_list "$MEDIA_PACKAGES"

    success "Essential tools installed"
}

# ╔══════════════════════════════════════════════════════════════╗
# ║ Cloud & DevOps Tools                                         ║
# ╚══════════════════════════════════════════════════════════════╝

install_cloud_tools() {
    info "Installing cloud and DevOps tools..."

    # kubectl
    install_with_fallback "kubectl" "kubectl" \
        'curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && chmod +x kubectl && sudo mv kubectl /usr/local/bin/'

    # Helm
    install_with_fallback "helm" "helm" \
        'curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash'

    # Terraform
    install_with_fallback "terraform" "terraform" \
        'TF_VERSION=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r .current_version) && wget "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip" && unzip "terraform_${TF_VERSION}_linux_amd64.zip" && sudo mv terraform /usr/local/bin/ && rm "terraform_${TF_VERSION}_linux_amd64.zip"'

    # Steampipe - SQL interface for cloud APIs
    if ! command_exists steampipe; then
        info "Installing steampipe..."
        if sudo /bin/sh -c "$(curl -fsSL https://steampipe.io/install/steampipe.sh)"; then
            success "steampipe installed successfully"
        else
            warning "Failed to install steampipe"
        fi
    else
        success "steampipe already installed"
    fi

    # AWS CLI
    install_with_fallback "aws" "awscli" \
        'curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip -q awscliv2.zip && sudo ./aws/install && rm -rf aws awscliv2.zip'

    # GCP SDK
    install_with_fallback "gcloud" "google-cloud-sdk" \
        'curl https://sdk.cloud.google.com | bash'

    # Docker (if not installed)
    if ! command_exists docker; then
        warning "Docker not installed. Please install Docker manually from https://docs.docker.com/get-docker/"
    else
        success "Docker already installed"
    fi

    success "Cloud tools installed"
}

install_k8s_tools() {
    info "Installing additional Kubernetes tools..."

    # On macOS, prefer Homebrew for all tools
    if [[ "$PKG_MANAGER" == "brew" ]]; then
        install_pkg "kubectx" "kubectx"
        install_pkg "k9s" "k9s"
        install_pkg "stern" "stern"
        install_pkg "kubetail" "kubetail"
        install_pkg "derailed/popeye/popeye" "popeye"
        install_pkg "robscott/tap/kube-capacity" "kube-capacity"
    else
        # Linux installations
        # kubectx and kubens
        install_with_fallback "kubectx" "kubectx" \
            'sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx && sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx && sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens'

        # k9s
        install_with_fallback "k9s" "k9s" \
            'curl -sS https://webinstall.dev/k9s | bash && export PATH="$HOME/.local/bin:$PATH"'

        # stern (log tailing)
        install_with_fallback "stern" "stern" \
            'github_install "stern/stern" "stern" "stern_{VERSION}_{OS}_{ARCH}.tar.gz"'

        # kubetail - multi-pod log tailing (bash script)
        if ! command_exists kubetail; then
            info "Installing kubetail..."
            if sudo curl -L https://raw.githubusercontent.com/johanhaleby/kubetail/master/kubetail -o /usr/local/bin/kubetail 2>/dev/null && sudo chmod +x /usr/local/bin/kubetail; then
                success "kubetail installed successfully"
            else
                warning "Failed to install kubetail"
            fi
        else
            success "kubetail already installed"
        fi

        # popeye - Kubernetes cluster sanitizer
        if ! command_exists popeye; then
            info "Installing popeye..."
            local version=$(curl -s https://api.github.com/repos/derailed/popeye/releases/latest | grep tag_name | cut -d '"' -f 4)
            if [[ -n "$version" ]]; then
                if [[ "$PKG_MANAGER" == "apt" ]]; then
                    curl -sL "https://github.com/derailed/popeye/releases/download/${version}/popeye_linux_amd64.deb" -o /tmp/popeye.deb && \
                    sudo dpkg -i /tmp/popeye.deb && rm /tmp/popeye.deb && \
                    success "popeye installed successfully"
                elif [[ "$PKG_MANAGER" == "dnf" ]]; then
                    sudo dnf install -y "https://github.com/derailed/popeye/releases/download/${version}/popeye_linux_amd64.rpm" && \
                    success "popeye installed successfully"
                else
                    # For other systems, extract tar.gz
                    curl -sL "https://github.com/derailed/popeye/releases/download/${version}/popeye_linux_amd64.tar.gz" -o /tmp/popeye.tar.gz && \
                    tar xzf /tmp/popeye.tar.gz -C /tmp && \
                    sudo mv /tmp/popeye /usr/local/bin/ && \
                    rm /tmp/popeye.tar.gz && \
                    success "popeye installed successfully"
                fi
            else
                warning "Failed to install popeye"
            fi
        else
            success "popeye already installed"
        fi

        # kube-capacity - resource capacity analysis
        if ! command_exists kube-capacity; then
            info "Installing kube-capacity..."
            github_install "robscott/kube-capacity" "kube-capacity" "kube-capacity_{VERSION}_{OS}_{ARCH}.tar.gz"
        else
            success "kube-capacity already installed"
        fi
    fi

    # krew - kubectl plugin manager (works same on all platforms)
    if ! command_exists kubectl-krew && ! [ -d "${HOME}/.krew" ]; then
        info "Installing krew..."
        (
            set -e
            cd "$(mktemp -d)"
            OS="$(uname | tr '[:upper:]' '[:lower:]')"
            ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')"
            KREW="krew-${OS}_${ARCH}"
            curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz"
            tar zxf "${KREW}.tar.gz"
            ./"${KREW}" install krew
            success "krew installed successfully"
        ) || warning "Failed to install krew"
    else
        success "krew already installed"
    fi

    success "Kubernetes tools installed"
}

# ╔══════════════════════════════════════════════════════════════╗
# ║ Security & IaC Tools                                         ║
# ╚══════════════════════════════════════════════════════════════╝

install_security_tools() {
    info "Installing security and IaC scanning tools..."

    # On macOS, prefer Homebrew for all tools
    if [[ "$PKG_MANAGER" == "brew" ]]; then
        install_pkg "trivy" "trivy"
        install_pkg "tfsec" "tfsec"
        install_pkg "tflint" "tflint"
        install_pkg "dive" "dive"
        install_pkg "yq" "yq"
        install_pkg "aws-vault" "aws-vault"
    else
        # Linux installations
        # trivy - security scanner for containers and IaC
        install_with_fallback "trivy" "trivy" \
            'curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin'

        # tfsec - Terraform security scanner
        if ! command_exists tfsec; then
            info "Installing tfsec..."
            github_install "aquasecurity/tfsec" "tfsec" "tfsec_{VERSION}_{OS}_{ARCH}.tar.gz"
        else
            success "tfsec already installed"
        fi

        # tflint - Terraform linter
        if ! command_exists tflint; then
            info "Installing tflint..."
            if curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash; then
                success "tflint installed successfully"
            else
                warning "Failed to install tflint"
            fi
        else
            success "tflint already installed"
        fi

        # dive - Docker image layer analyzer
        if ! command_exists dive; then
            info "Installing dive..."
            github_install "wagoodman/dive" "dive" "dive_{VERSION}_{OS}_{ARCH}.tar.gz"
        else
            success "dive already installed"
        fi

        # yq - YAML processor
        if ! command_exists yq; then
            info "Installing yq..."
            local version=$(curl -s https://api.github.com/repos/mikefarah/yq/releases/latest | grep tag_name | cut -d '"' -f 4)
            if [[ -n "$version" ]]; then
                sudo curl -sL "https://github.com/mikefarah/yq/releases/download/${version}/yq_linux_amd64" -o /usr/local/bin/yq && \
                sudo chmod +x /usr/local/bin/yq && \
                success "yq installed successfully" || warning "Failed to install yq"
            else
                warning "Failed to install yq"
            fi
        else
            success "yq already installed"
        fi

        # aws-vault - secure AWS credential manager
        if ! command_exists aws-vault; then
            info "Installing aws-vault..."
            local version=$(curl -s https://api.github.com/repos/99designs/aws-vault/releases/latest | grep tag_name | cut -d '"' -f 4)
            if [[ -n "$version" ]]; then
                sudo curl -sL "https://github.com/99designs/aws-vault/releases/download/${version}/aws-vault-linux-amd64" -o /usr/local/bin/aws-vault && \
                sudo chmod +x /usr/local/bin/aws-vault && \
                success "aws-vault installed successfully" || warning "Failed to install aws-vault"
            else
                warning "Failed to install aws-vault"
            fi
        else
            success "aws-vault already installed"
        fi
    fi

    success "Security and IaC tools installed"
}

# ╔══════════════════════════════════════════════════════════════╗
# ║ Shell Enhancements                                           ║
# ╚══════════════════════════════════════════════════════════════╝

install_shell_tools() {
    info "Installing shell enhancements..."

    # Starship prompt
    install_with_fallback "starship" "starship" \
        'curl -sS https://starship.rs/install.sh | sh -s -- -y'

    # ZSH plugins
    install_zsh_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions"
    install_zsh_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting"
    install_zsh_plugin "fzf-tab" "https://github.com/Aloxaf/fzf-tab"

    # mise version manager (replaces asdf - much faster!)
    install_with_fallback "mise" "mise" \
        'curl https://mise.run | sh && export PATH="$HOME/.local/bin:$PATH"'

    success "Shell tools installed"
}

install_nushell() {
    info "Installing Nushell..."

    # Check if nushell is already installed
    if command_exists nu; then
        success "Nushell is already installed"
    else
        # Install nushell via package manager or cargo
        case $PKG_MANAGER in
            apt)
                # For Ubuntu/Debian, use cargo for latest version
                if command_exists cargo; then
                    info "Installing nushell via cargo..."
                    cargo install nu --features=extra --locked
                else
                    warning "Cargo not found. Install Rust first or use package manager"
                    return 1
                fi
                ;;
            dnf)
                # Fedora has nushell in repos
                install_pkg "nushell"
                ;;
            brew)
                # macOS via Homebrew
                install_pkg "nushell"
                ;;
            pacman)
                # Arch Linux
                install_pkg "nushell"
                ;;
            *)
                warning "Unknown package manager, trying cargo..."
                if command_exists cargo; then
                    cargo install nu --features=extra --locked
                else
                    error "Could not install nushell. Install Rust/cargo first."
                    return 1
                fi
                ;;
        esac
    fi

    # Set up vendor autoload directory for third-party integrations
    info "Setting up nushell integrations..."
    # Use correct path for macOS vs Linux
    if [ "$(uname)" = "Darwin" ]; then
        local vendor_dir="$HOME/Library/Application Support/nushell/vendor/autoload"
    else
        local vendor_dir="$HOME/.local/share/nushell/vendor/autoload"
    fi
    mkdir -p "$vendor_dir"

    # Starship integration is configured directly in config.nu
    # Skip vendor autoload generation to avoid parse errors
    # if command_exists starship; then
    #     info "Generating starship integration for nushell..."
    #     starship init nu > "$vendor_dir/starship.nu"
    # fi

    # Generate zoxide integration
    if command_exists zoxide; then
        info "Generating zoxide integration for nushell..."
        zoxide init nushell > "$vendor_dir/zoxide.nu"
    fi

    # Generate carapace integration
    if command_exists carapace; then
        info "Generating carapace integration for nushell..."
        carapace _carapace nushell > "$vendor_dir/carapace.nu"
    fi

    success "Nushell installed and configured!"
}

# ╔══════════════════════════════════════════════════════════════╗
# ║ Stow Dotfiles                                                ║
# ╚══════════════════════════════════════════════════════════════╝

stow_dotfiles() {
    info "Linking dotfiles with GNU Stow..."

    # Handle nushell config directory conflict
    # Nushell creates default config on first run, which conflicts with stow
    if [ -d "$HOME/.config/nushell" ] && [ ! -L "$HOME/.config/nushell" ]; then
        warning "Existing nushell config directory found"

        # Check if backup already exists
        if [ -d "$HOME/.config/nushell.backup" ]; then
            warning "Backup already exists at ~/.config/nushell.backup"
            info "Removing auto-generated nushell config (stow will create symlink)..."
            rm -rf "$HOME/.config/nushell"
        else
            info "Backing up to ~/.config/nushell.backup..."
            mv "$HOME/.config/nushell" "$HOME/.config/nushell.backup"
        fi
    fi

    # Call dotfiles.sh to handle stow operations
    "$DOTFILES_DIR/dotfiles.sh"

    success "Dotfiles linked"

    # Install yazi plugins if yazi is installed
    if command_exists yazi; then
        info "Installing yazi plugins and themes..."
        if [ -f "$DOTFILES_DIR/yazi/install-plugins.sh" ]; then
            bash "$DOTFILES_DIR/yazi/install-plugins.sh"
        else
            warning "Yazi plugin installer not found, skipping..."
        fi
    fi
}

# ╔══════════════════════════════════════════════════════════════╗
# ║ Change Default Shell                                         ║
# ╚══════════════════════════════════════════════════════════════╝

change_shell() {
    if [ "$SHELL" != "$(which zsh)" ]; then
        info "Changing default shell to zsh..."
        chsh -s "$(which zsh)"
        success "Default shell changed to zsh (restart your terminal)"
    else
        success "Zsh is already your default shell"
    fi
}

# ╔══════════════════════════════════════════════════════════════╗
# ║ Main Installation Flow                                       ║
# ╚══════════════════════════════════════════════════════════════╝

main() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║          Dotfiles Bootstrap - Cloud DevOps Setup             ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"

    local mode="full"

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --minimal)
                mode="minimal"
                shift
                ;;
            --full)
                mode="full"
                shift
                ;;
            --help)
                echo "Usage: $0 [--minimal|--full|--help]"
                echo ""
                echo "Options:"
                echo "  --minimal     Install only essential tools"
                echo "  --full        Install everything (default)"
                echo "  --help        Show this help message"
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                exit 1
                ;;
        esac
    done

    info "Installation mode: $mode"
    echo ""

    # Run installations
    detect_os
    install_package_manager
    install_essentials

    if [[ "$mode" == "full" ]]; then
        install_cloud_tools
        install_k8s_tools
        install_security_tools
    fi

    install_shell_tools
    install_nushell
    stow_dotfiles
    change_shell

    echo ""
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                  Installation Complete!                      ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Restart your terminal or run: exec zsh"
    echo "  2. Configure your cloud providers:"
    echo "     - AWS: aws configure"
    echo "     - GCP: gcloud init"
    echo "     - Kubernetes: kubectl config view"
    echo "  3. Customize ~/.config/starship.toml for your prompt"
    echo "  4. Add secrets to ~/.secrets if needed"
    echo ""
}

# Run main function
main "$@"
