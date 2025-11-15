#!/usr/bin/env bash

# ╔══════════════════════════════════════════════════════════════╗
# ║ Tool Verification Script                                     ║
# ╚══════════════════════════════════════════════════════════════╝
#
# Verifies that all tools from bootstrap.sh are installed correctly.
# Run after bootstrap.sh to ensure everything works.

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          Tool Verification - Security & K8s Tools            ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Track counts
TOTAL=0
PASSED=0
FAILED=0

# Check if command exists and can show version
check_tool() {
    local tool=$1
    local version_cmd=$2
    local description=$3

    TOTAL=$((TOTAL + 1))

    if command -v "$tool" &> /dev/null; then
        # Try to get version - capture both stdout and stderr
        local version_output=$(eval "$version_cmd" 2>&1)
        local exit_code=$?

        # Check if we got any output (ignore exit code, some tools return non-zero)
        if [[ -n "$version_output" ]]; then
            local version=$(echo "$version_output" | head -1)
            echo -e "${GREEN}✅${NC} $tool - $description"
            echo -e "   ${BLUE}→${NC} $version"
            PASSED=$((PASSED + 1))
            return 0
        else
            # Tool exists but couldn't get version - still count as installed
            echo -e "${GREEN}✅${NC} $tool - $description"
            echo -e "   ${BLUE}→${NC} (installed, version unavailable)"
            PASSED=$((PASSED + 1))
            return 0
        fi
    else
        echo -e "${RED}❌${NC} $tool - $description (not installed)"
        FAILED=$((FAILED + 1))
        return 1
    fi
}

# Check for directory-based tools
check_dir() {
    local dir=$1
    local name=$2
    local description=$3

    TOTAL=$((TOTAL + 1))

    if [ -d "$dir" ]; then
        echo -e "${GREEN}✅${NC} $name - $description"
        echo -e "   ${BLUE}→${NC} Found at: $dir"
        PASSED=$((PASSED + 1))
        return 0
    else
        echo -e "${RED}❌${NC} $name - $description (not found)"
        FAILED=$((FAILED + 1))
        return 1
    fi
}

echo -e "${BLUE}Kubernetes Tools:${NC}"
echo ""
check_tool "kubectl" "kubectl version --client --short 2>&1 | head -1" "Kubernetes CLI"
check_tool "helm" "helm version --short" "Kubernetes package manager"
check_tool "k9s" "k9s version --short" "Kubernetes TUI"
check_tool "kubectx" "kubectx --help 2>&1 | head -1" "Context switcher"
check_tool "kubens" "kubens --help 2>&1 | head -1" "Namespace switcher"
check_tool "stern" "stern --version" "Multi-pod log tailing"
check_tool "kubetail" "file \$(which kubetail) | grep -o 'shell script' || kubetail --version 2>&1 | head -1" "Multi-pod log tailing (alt)"
check_tool "popeye" "popeye version 2>&1 | head -1" "Cluster sanitizer"
check_tool "kube-capacity" "kube-capacity --version 2>&1 | head -1" "Resource analysis"
check_dir "$HOME/.krew" "krew" "kubectl plugin manager"
echo ""

echo -e "${BLUE}Security & IaC Tools:${NC}"
echo ""
check_tool "trivy" "trivy --version 2>&1 | head -1" "Security scanner"
check_tool "tfsec" "tfsec --version 2>&1 | head -1" "Terraform security"
check_tool "tflint" "tflint --version 2>&1 | head -1" "Terraform linter"
check_tool "dive" "dive --version 2>&1 | head -1" "Docker image analyzer"
echo ""

echo -e "${BLUE}CLI Tools:${NC}"
echo ""
check_tool "yq" "yq --version 2>&1 | head -1" "YAML processor"
check_tool "jq" "jq --version 2>&1 | head -1" "JSON processor"
check_tool "fzf" "fzf --version 2>&1 | head -1" "Fuzzy finder"
check_tool "bat" "bat --version 2>&1 | head -1" "Cat with syntax highlighting"
check_tool "eza" "eza --version 2>&1 | head -1" "Modern ls replacement"
check_tool "fd" "fd --version 2>&1 | head -1" "Fast find"
check_tool "rg" "rg --version 2>&1 | head -1" "Ripgrep"
check_tool "zoxide" "zoxide --version 2>&1 | head -1" "Smart cd"
check_tool "starship" "starship --version 2>&1 | head -1" "Shell prompt"
echo ""

echo -e "${BLUE}Cloud Tools:${NC}"
echo ""
check_tool "aws" "aws --version 2>&1 | head -1" "AWS CLI"
check_tool "aws-vault" "aws-vault --version 2>&1 | head -1" "Secure AWS credentials"
check_tool "gcloud" "gcloud --version 2>&1 | head -1" "Google Cloud SDK"
check_tool "terraform" "terraform version 2>&1 | head -1" "Infrastructure as Code"
check_tool "steampipe" "steampipe --version 2>&1 | head -1" "SQL interface for cloud APIs"
check_tool "docker" "docker --version 2>&1 | head -1" "Container platform"
echo ""

echo -e "${BLUE}Version Manager:${NC}"
echo ""
check_tool "mise" "mise --version 2>&1 | head -1" "Fast version manager"
echo ""

echo -e "${BLUE}Shell Tools:${NC}"
echo ""
check_tool "zsh" "zsh --version 2>&1 | head -1" "Z Shell"
check_tool "git" "git --version 2>&1 | head -1" "Version control"
check_tool "tmux" "tmux -V 2>&1 | head -1" "Terminal multiplexer"
check_tool "vim" "vim --version 2>&1 | head -1" "Text editor"
check_tool "nu" "nu --version 2>&1 | head -1" "Nushell"
echo ""

# Summary
echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                      Summary                                 ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Total tools checked: ${BLUE}$TOTAL${NC}"
echo -e "Passed: ${GREEN}$PASSED${NC}"
echo -e "Failed: ${RED}$FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All tools installed successfully!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Restart your shell: exec zsh"
    echo "  2. Try out the new tools:"
    echo "     - check-security-tools"
    echo "     - trscan nginx:latest"
    echo "     - kpop (if connected to a cluster)"
    echo "  3. Check documentation:"
    echo "     - cat docs/TOOLS.md"
    echo "     - cat docs/USER_GUIDE.md"
    exit 0
else
    echo -e "${YELLOW}⚠️  Some tools are missing${NC}"
    echo ""
    echo "To install missing tools:"
    echo "  cd ~/dotfiles"
    echo "  ./bootstrap.sh --full"
    echo ""
    echo "To check what went wrong:"
    echo "  cat full_install.log"
    exit 1
fi
