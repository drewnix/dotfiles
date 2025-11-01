#!/usr/bin/env bash

# ╔══════════════════════════════════════════════════════════════╗
# ║ Dotfiles Bootstrap Script                                    ║
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
# ║ Helper Functions                                             ║
# ╚══════════════════════════════════════════════════════════════╝

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

    # GNU Stow for dotfiles management
    install_pkg stow "GNU Stow"

    # Git
    install_pkg git "Git"

    # Zsh
    install_pkg zsh "Zsh"

    # Curl and wget
    install_pkg curl "cURL"
    install_pkg wget "wget"

    # Build tools
    if [[ "$PKG_MANAGER" == "apt" ]]; then
        install_pkg build-essential "Build Essential"
    fi

    # Modern CLI tools
    install_pkg fzf "fzf (fuzzy finder)"
    install_pkg ripgrep "ripgrep"

    # fd installation (different package names)
    if [[ "$PKG_MANAGER" == "apt" ]]; then
        install_pkg fd-find "fd"
    else
        install_pkg fd "fd"
    fi

    # bat installation (different package names)
    if [[ "$PKG_MANAGER" == "dnf" ]]; then
        install_pkg bat "bat (better cat)"
    else
        install_pkg bat "bat (better cat)"
    fi

    # eza - modern ls replacement with icons and git integration
    if ! command_exists eza; then
        info "Installing eza..."
        case $PKG_MANAGER in
            brew)
                brew install eza
                ;;
            apt)
                # Ubuntu 24.04+ / Debian 13+ have eza in repos
                if sudo apt install -y eza 2>/dev/null; then
                    success "eza installed from apt"
                else
                    # Fallback: install from GitHub releases
                    warning "eza not in apt repos, installing from GitHub..."
                    EZA_VERSION=$(curl -s https://api.github.com/repos/eza-community/eza/releases/latest | grep tag_name | cut -d '"' -f 4)
                    curl -L "https://github.com/eza-community/eza/releases/download/${EZA_VERSION}/eza_x86_64-unknown-linux-gnu.tar.gz" -o eza.tar.gz
                    tar xzf eza.tar.gz
                    sudo mv eza /usr/local/bin/
                    rm eza.tar.gz
                fi
                ;;
            dnf)
                # Try dnf first (newer Fedora versions may have it)
                if sudo dnf install -y eza 2>/dev/null; then
                    success "eza installed from dnf"
                else
                    # Fallback: install from GitHub releases
                    warning "eza not in dnf repos, installing from GitHub..."
                    EZA_VERSION=$(curl -s https://api.github.com/repos/eza-community/eza/releases/latest | grep tag_name | cut -d '"' -f 4)
                    curl -L "https://github.com/eza-community/eza/releases/download/${EZA_VERSION}/eza_x86_64-unknown-linux-gnu.tar.gz" -o eza.tar.gz
                    tar xzf eza.tar.gz
                    sudo mv eza /usr/local/bin/
                    rm eza.tar.gz
                fi
                ;;
            pacman)
                sudo pacman -S --noconfirm eza
                ;;
            *)
                warning "Installing eza from GitHub releases..."
                EZA_VERSION=$(curl -s https://api.github.com/repos/eza-community/eza/releases/latest | grep tag_name | cut -d '"' -f 4)
                curl -L "https://github.com/eza-community/eza/releases/download/${EZA_VERSION}/eza_x86_64-unknown-linux-gnu.tar.gz" -o eza.tar.gz
                tar xzf eza.tar.gz
                sudo mv eza /usr/local/bin/
                rm eza.tar.gz
                ;;
        esac

        if command_exists eza; then
            success "eza installed successfully"
        fi
    else
        success "eza already installed"
    fi

    success "Essential tools installed"
}

# ╔══════════════════════════════════════════════════════════════╗
# ║ Cloud & DevOps Tools                                         ║
# ╚══════════════════════════════════════════════════════════════╝

install_cloud_tools() {
    info "Installing cloud and DevOps tools..."

    # kubectl
    if ! command_exists kubectl; then
        info "Installing kubectl..."
        if [[ "$OS" == "macos" ]]; then
            brew install kubectl
        else
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
            chmod +x kubectl
            sudo mv kubectl /usr/local/bin/
        fi
        success "kubectl installed"
    else
        success "kubectl already installed"
    fi

    # Helm
    if ! command_exists helm; then
        info "Installing Helm..."
        curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
        success "Helm installed"
    else
        success "Helm already installed"
    fi

    # Terraform
    if ! command_exists terraform; then
        info "Installing Terraform..."
        if [[ "$OS" == "macos" ]]; then
            brew tap hashicorp/tap
            brew install hashicorp/tap/terraform
        elif [[ "$PKG_MANAGER" == "dnf" ]]; then
            # Fedora/RHEL/CentOS - create repo file directly
            sudo tee /etc/yum.repos.d/hashicorp.repo > /dev/null <<EOF
[hashicorp]
name=Hashicorp Stable - \$basearch
baseurl=https://rpm.releases.hashicorp.com/fedora/\$releasever/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://rpm.releases.hashicorp.com/gpg
EOF
            sudo dnf install -y terraform
        elif [[ "$PKG_MANAGER" == "apt" ]]; then
            # Ubuntu/Debian
            sudo mkdir -p /usr/share/keyrings
            wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
            echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
            sudo apt update && sudo apt install terraform
        else
            # Fallback: download binary directly
            warning "Installing Terraform from binary..."
            TF_VERSION=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r .current_version)
            wget "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip"
            unzip "terraform_${TF_VERSION}_linux_amd64.zip"
            sudo mv terraform /usr/local/bin/
            rm "terraform_${TF_VERSION}_linux_amd64.zip"
        fi
        success "Terraform installed"
    else
        success "Terraform already installed"
    fi

    # AWS CLI
    if ! command_exists aws; then
        info "Installing AWS CLI..."
        if [[ "$OS" == "macos" ]]; then
            brew install awscli
        elif [[ "$PKG_MANAGER" == "dnf" ]]; then
            # Fedora has awscli2 in repos
            sudo dnf install -y awscli2 || {
                # Fallback to manual installation
                curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
                unzip -q awscliv2.zip
                sudo ./aws/install
                rm -rf aws awscliv2.zip
            }
        else
            curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
            unzip -q awscliv2.zip
            sudo ./aws/install
            rm -rf aws awscliv2.zip
        fi
        success "AWS CLI installed"
    else
        success "AWS CLI already installed"
    fi

    # GCP SDK
    if ! command_exists gcloud; then
        info "Installing Google Cloud SDK..."
        if [[ "$OS" == "macos" ]]; then
            brew install google-cloud-sdk
        elif [[ "$PKG_MANAGER" == "dnf" ]]; then
            # Fedora - use package manager
            sudo tee /etc/yum.repos.d/google-cloud-sdk.repo > /dev/null <<EOF
[google-cloud-cli]
name=Google Cloud CLI
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el9-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
            sudo dnf install -y google-cloud-cli
        else
            # Ubuntu/Debian or other
            curl https://sdk.cloud.google.com | bash
            # Note: User needs to restart shell for PATH update
        fi
        success "Google Cloud SDK installed"
    else
        success "GCP SDK already installed"
    fi

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

    # kubectx and kubens
    if ! command_exists kubectx; then
        info "Installing kubectx and kubens..."
        if [[ "$OS" == "macos" ]]; then
            brew install kubectx
        else
            sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
            sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
            sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens
        fi
        success "kubectx and kubens installed"
    else
        success "kubectx already installed"
    fi

    # k9s
    if ! command_exists k9s; then
        info "Installing k9s..."
        if [[ "$OS" == "macos" ]]; then
            brew install k9s
        else
            curl -sS https://webinstall.dev/k9s | bash
            export PATH="$HOME/.local/bin:$PATH"
        fi
        success "k9s installed"
    else
        success "k9s already installed"
    fi

    # stern (log tailing)
    if ! command_exists stern; then
        info "Installing stern..."
        if [[ "$OS" == "macos" ]]; then
            brew install stern
        else
            STERN_VERSION=$(curl -s https://api.github.com/repos/stern/stern/releases/latest | grep tag_name | cut -d '"' -f 4)
            curl -L "https://github.com/stern/stern/releases/download/${STERN_VERSION}/stern_${STERN_VERSION#v}_linux_amd64.tar.gz" -o stern.tar.gz
            tar xzf stern.tar.gz
            sudo mv stern /usr/local/bin/
            rm stern.tar.gz
        fi
        success "stern installed"
    else
        success "stern already installed"
    fi

    success "Kubernetes tools installed"
}

# ╔══════════════════════════════════════════════════════════════╗
# ║ Shell Enhancements                                           ║
# ╚══════════════════════════════════════════════════════════════╝

install_shell_tools() {
    info "Installing shell enhancements..."

    # Starship prompt
    if ! command_exists starship; then
        info "Installing Starship prompt..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
        success "Starship installed"
    else
        success "Starship already installed"
    fi

    # zsh-autosuggestions
    if [ ! -d "$HOME/.zsh/zsh-autosuggestions" ]; then
        info "Installing zsh-autosuggestions..."
        mkdir -p "$HOME/.zsh"
        git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME/.zsh/zsh-autosuggestions"
        success "zsh-autosuggestions installed"
    else
        success "zsh-autosuggestions already installed"
    fi

    # zsh-syntax-highlighting
    if [ ! -d "$HOME/.zsh/zsh-syntax-highlighting" ]; then
        info "Installing zsh-syntax-highlighting..."
        mkdir -p "$HOME/.zsh"
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$HOME/.zsh/zsh-syntax-highlighting"
        success "zsh-syntax-highlighting installed"
    else
        success "zsh-syntax-highlighting already installed"
    fi

    # mise version manager (replaces asdf - much faster!)
    if ! command_exists mise; then
        info "Installing mise version manager..."
        if [[ "$OS" == "macos" ]]; then
            brew install mise
        else
            curl https://mise.run | sh
            # Add to PATH for current session
            export PATH="$HOME/.local/bin:$PATH"
        fi
        success "mise installed"
    else
        success "mise already installed"
    fi

    success "Shell tools installed"
}

# ╔══════════════════════════════════════════════════════════════╗
# ║ Stow Dotfiles                                                ║
# ╚══════════════════════════════════════════════════════════════╝

stow_dotfiles() {
    info "Linking dotfiles with GNU Stow..."

    # Call dotfiles.sh to handle stow operations
    "$DOTFILES_DIR/dotfiles.sh"

    success "Dotfiles linked"
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
    fi

    install_shell_tools
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
