```text
██████╗ ██████╗ ███████╗██╗    ██╗███╗   ██╗██╗██╗  ██╗
██╔══██╗██╔══██╗██╔════╝██║    ██║████╗  ██║██║╚██╗██╔╝
██║  ██║██████╔╝█████╗  ██║ █╗ ██║██╔██╗ ██║██║ ╚███╔╝
██║  ██║██╔══██╗██╔══╝  ██║███╗██║██║╚██╗██║██║ ██╔██╗
██████╔╝██║  ██║███████╗╚███╔███╔╝██║ ╚████║██║██╔╝ ██╗
╚═════╝ ╚═╝  ╚═╝╚══════╝ ╚══╝╚══╝ ╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝
                                                      
██████╗ ██████╗█████████████████╗██╗    ██████████████╗
██╔══████╔═══██╚══██╔══██╔════██║██║    ██╔════██╔════╝
██║  ████║   ██║  ██║  █████╗ ██║██║    █████╗ ███████╗
██║  ████║   ██║  ██║  ██╔══╝ ██║██║    ██╔══╝ ╚════██║
██████╔╚██████╔╝  ██║  ██║    ██║█████████████████████║
╚═════╝ ╚═════╝   ╚═╝  ╚═╝    ╚═╝╚══════╚══════╚══════╝
```

Here are my carefully crafted, artisinal, and opinionated dotfiles. These are mostly optimized for
cloud-native development and DevOps workflows based around Kubernetes, Terraform, AWS, GCP, and Docker.

## Features

### Modular Shell Configuration

- **ZSH** with organized, modular configuration
- **Nushell** - Modern shell with structured data pipelines (NEW!)
- Separate alias files for different tools (Kubernetes, Terraform, AWS, GCP, Docker, Git)
- Full feature parity between ZSH and Nushell configurations
- Easy to customize and extend

### Cloud & DevOps Aliases

- **200+ Kubernetes aliases** - kubectl, helm, k9s, kubectx, stern, kubetail, popeye, kube-capacity, krew
- **Terraform shortcuts** - workspace management, plan/apply helpers, linting (tflint), security (tfsec)
- **AWS CLI helpers** - EC2, S3, EKS, Lambda, IAM shortcuts, secure credential management (aws-vault)
- **GCP/gcloud aliases** - GKE, GCE, Cloud Run, Cloud Functions
- **Docker & containers** - comprehensive docker/docker-compose aliases, image analysis (dive)
- **Git workflow** - enhanced git operations and shortcuts
- **Security scanning** - trivy for containers/IaC, tfsec/tflint for Terraform, vulnerability detection

### Modern CLI Tools

- **Starship** - Beautiful, fast, customizable prompt
- **fzf** - Fuzzy finder integration for contexts, files, history
- **mise** - Lightning-fast version manager (10-100x faster than asdf)
- **eza** - Modern ls replacement with icons, git integration, and smart directory grouping
- **bat** - Syntax-highlighted cat alternative
- **fd** - Fast and user-friendly find replacement
- **ripgrep** - Lightning-fast grep alternative
- **yq** - YAML processor (like jq but for YAML) - essential for Kubernetes manifests

### Smart Features

- Auto-completion for kubectl, terraform, aws, gcloud
- SSH key auto-loading
- Context-aware Kubernetes/AWS/GCP information in prompt
- FZF integration for quick context switching
- Syntax highlighting and autosuggestions
- Claude code settings for advanced vibe coding

## Quick Start

### 1. Automated Installation (Recommended)

```bash
# Clone the repository
git clone https://github.com/drewnix/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Run bootstrap script (installs tools + dotfiles)
./bootstrap.sh

# Or minimal install (dotfiles only, no tool installation)
./bootstrap.sh --minimal
```

The bootstrap script will:

- Install essential tools (kubectl, terraform, aws-cli, gcloud, docker tools, etc.)
- Install modern CLI enhancements (starship, fzf, bat, eza, mise, etc.)
- Symlink dotfiles using GNU Stow
- Set up ZSH as your default shell

### 2. Manual Installation

If you prefer manual control:

```bash
# 1. Install GNU Stow
# macOS:
brew install stow

# Ubuntu/Debian:
sudo apt install stow

# Fedora
sudo dnf install stow

# 2. Clone dotfiles
git clone https://github.com/drewnix/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 3. Install specific packages
./dotfiles.sh zsh git tmux

# Or install everything
./dotfiles.sh --all

# 4. Install tools manually as needed
# See "Tools Installation" section below
```

## Repository Structure

```text
dotfiles/
├── zsh/                          # ZSH configuration
│   ├── .zshrc                    # Main ZSH config (loads modules)
│   └── .config/zsh/
│       ├── env.zsh               # Environment variables & paths
│       └── aliases/
│           ├── kubernetes.zsh    # Kubernetes/kubectl aliases
│           ├── terraform.zsh     # Terraform aliases
│           ├── aws.zsh           # AWS CLI aliases
│           ├── gcp.zsh           # GCP/gcloud aliases
│           ├── docker.zsh        # Docker & containers
│           ├── git.zsh           # Git workflow aliases
│           └── general.zsh       # General utilities
├── git/                          # Git configuration
│   └── .gitconfig
├── tmux/                         # Tmux configuration
│   └── .config/tmux/
│       └── tmux.conf
├── vim/                          # Vim configuration
│   └── .vimrc
├── aws/                          # AWS CLI config
│   └── .aws/config
├── starship/                     # Starship prompt config
│   └── .config/starship.toml
├── mise/                         # mise version manager
│   ├── .tool-versions
│   └── .config/mise/config.toml
├── bootstrap.sh                  # Automated installation script
├── dotfiles.sh                   # GNU Stow installer
└── README.md                     # This file
```

## Configuration Files

### ZSH Configuration

The main `.zshrc` automatically loads modular configurations:

- **env.zsh** - PATH, environment variables, completions
- **kubernetes.zsh** - kubectl, helm, k9s, kubectx, stern
- **terraform.zsh** - terraform, terragrunt
- **aws.zsh** - AWS CLI helpers and shortcuts
- **gcp.zsh** - GCP/gcloud commands
- **docker.zsh** - Docker and docker-compose
- **git.zsh** - Git workflows and shortcuts
- **general.zsh** - General utilities and functions

Each module can be customized independently without affecting others.

### Nushell Configuration

Nushell provides a modern, structured data-first shell experience with full feature parity to ZSH:

**Autoload Architecture** - Modern configuration using numbered autoload files:
- **01-environment.nu** - PATH, environment variables, core settings
- **02-integrations.nu** - Starship, zoxide, carapace, direnv, mise
- **10-aliases-general.nu** - Navigation, file ops, utilities
- **11-aliases-git.nu** - Git workflows (identical to ZSH)
- **12-aliases-k8s.nu** - 200+ Kubernetes aliases and helpers
- **13-aliases-terraform.nu** - Terraform/Terragrunt/IaC workflows
- **14-aliases-docker.nu** - Docker and container management
- **15-aliases-aws.nu** - AWS CLI helpers and commands
- **16-aliases-gcp.nu** - GCP/gcloud operations
- **20-completions.nu** - Custom completions for contexts, profiles, workspaces
- **99-local.nu** - Machine-specific overrides (template)

**Key Nushell Advantages:**
- **Structured data** - Commands return tables/records instead of text
- **Type safety** - Parameters have types and automatic validation
- **Pipeline-friendly** - Filter, sort, and transform data natively
- **Advanced completions** - Custom completions for kubectl contexts, AWS profiles, GCP projects, etc.
- **FZF integration** - Interactive selectors for all cloud resources
- **Better error handling** - Clear error messages with context

**Quick Start with Nushell:**
```bash
# Launch nushell
nu

# Or set as interactive shell (while keeping bash/zsh as login shell)
echo '[ -x /usr/bin/nu ] && exec nu' >> ~/.bashrc

# Try structured data pipelines
kubectl get pods | from json | where status.phase == "Running"
docker ps --format json | from json | where State == "running" | select Names Image Status

# Use custom completions
kubectl-use-context <TAB>    # Shows all contexts
aws-use-profile <TAB>         # Shows all AWS profiles
tf-workspace-select <TAB>     # Shows all workspaces
```

Configuration: `~/.config/nushell/`

### Starship Prompt

Configured to show:

- Current directory with Git status
- Kubernetes context and namespace
- Terraform workspace
- AWS profile and region
- GCP project
- Docker context
- Command duration
- Time

Customize: `~/.config/starship.toml`

### mise Version Manager

```bash
# Install tools globally
mise use --global nodejs@20 python@3.12 terraform@latest

# Or use .tool-versions file in projects
echo "nodejs 20.11.0" >> .tool-versions
echo "terraform latest" >> .tool-versions
mise install

# List available tools
mise ls-remote nodejs
mise ls-remote terraform

# Built-in tools (no plugins needed):
# - nodejs, python, golang, rust, java, ruby, php
# - terraform, kubectl, helm
# - And many more!
```

Configure: `~/.config/mise/config.toml`

## Alias Examples

### Kubernetes

```bash
# Context & Namespace
k config current-context          # Current context
kns production                    # Switch namespace
kctx staging                      # Switch context (with kubectx)

# Resources
kgp                               # Get pods
kgpa                              # Get all pods across namespaces
kgd                               # Get deployments
kgsvc                             # Get services

# Logs & Exec
klog nginx                        # Tail logs for pod matching "nginx"
kexe nginx                        # Exec into pod matching "nginx"

# Quick operations
kd pod-name                       # Describe pod
kdel pod-name                     # Delete pod
kinfo                             # Show current context info
```

### Terraform

```bash
# Basic workflow
tfi                               # terraform init
tfp                               # terraform plan
tfa                               # terraform apply
tfaa                              # terraform apply -auto-approve

# Workspace management
tfws production                   # Select workspace
tfwl                              # List workspaces
tfwsp production                  # Switch workspace and plan

# State
tfsl                              # List state
tfss resource.name                # Show state resource
tfinfo                            # Show workspace and state info
```

### AWS

```bash
# Identity
aws-whoami                        # Show current AWS identity

# EC2
ec2-ls                            # List EC2 instances
ec2-ssh web-server                # SSH to instance by name
ec2-ssm web-server                # SSM connect to instance

# EKS
eks-use my-cluster                # Update kubeconfig for cluster

# S3
s3-ls                             # List buckets
s3-cp file.txt s3://bucket/       # Upload file

# Profile switching (with fzf)
awsp-select                       # Fuzzy search AWS profiles
```

### GCP

```bash
# Identity
gcp-whoami                        # Show current GCP config

# GKE
gke-use my-cluster                # Get GKE credentials
gke-ls                            # List clusters

# GCE
gce-ls                            # List compute instances
gce-ssh-name web-server           # SSH to instance by name

# Projects
gproj-select                      # Fuzzy search projects (requires fzf)
gproj-set my-project              # Set project
gcp-switch my-project             # Switch project + update k8s config
```

### Docker

```bash
# Quick operations
dps                               # List containers
dex nginx                         # Exec into container matching "nginx"
dlog nginx -f                     # Follow logs for container

# Cleanup
dstopall                          # Stop all containers
dclean                            # Clean everything (careful!)

# Docker Compose
dcu                               # docker-compose up
dcud                              # docker-compose up -d
dcd                               # docker-compose down
dclogsvc web                      # Logs for specific service
```

### Git

```bash
# Quick commits
gcq "commit message"              # Add all + commit
gcp-push "commit message"         # Add all + commit + push

# Branch management
gnb feature-branch                # Create new branch
gbrecent                          # Show recent branches
gclean-merged                     # Delete merged branches

# Logs
glog                              # Pretty graph log
gloga                             # All branches graph
gfind "search term"               # Find commits by message
ginfo                             # Show repo info
```

## Tools Installation

The `bootstrap.sh` script installs these tools automatically. For manual installation:

### Essential Tools

```bash
# macOS
brew install kubectl helm terraform awscli google-cloud-sdk docker \
  kubectx k9s stern starship fzf bat eza fd ripgrep mise

# Ubuntu/Debian
# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# mise (version manager)
curl https://mise.run | sh

# Starship
curl -sS https://starship.rs/install.sh | sh
```

### Version Manager (mise)

```bash
# Install mise
curl https://mise.run | sh

# Or with homebrew
brew install mise

# Install common tools
mise use --global nodejs@lts python@latest golang@latest terraform@latest

# For project-specific versions, use .tool-versions file
echo "nodejs 20.11.0" >> ~/myproject/.tool-versions
echo "terraform 1.7.0" >> ~/myproject/.tool-versions
cd ~/myproject
mise install  # Installs all tools from .tool-versions
```

## Customization

### Adding Your Own Aliases

Create `~/.zshrc.local` for personal additions (automatically loaded):

```bash
# ~/.zshrc.local
export MY_CUSTOM_VAR="value"
alias myalias="my-command"
```

### Company-Specific Config

The `.zshrc` sources `~/.zshrc.spl` if it exists - useful for company-specific configurations.

### Secrets Management

Create `~/.secrets` for API keys and sensitive data:

```bash
# ~/.secrets
export GITHUB_TOKEN="ghp_xxx"
export MY_API_KEY="xxx"
```

This file is automatically sourced and should be added to `.gitignore`.

## Cloud Provider Setup

### AWS Configuration

```bash
# Configure AWS CLI
aws configure

# Or use aws-vault for better security
brew install aws-vault
aws-vault add my-profile
aws-vault exec my-profile -- aws s3 ls
```

### GCP Configuration

```bash
# Initialize gcloud
gcloud init

# Configure kubectl for GKE
gcloud container clusters get-credentials CLUSTER_NAME --region REGION
```

### Kubernetes Configuration

```bash
# Add kubeconfig
export KUBECONFIG=~/.kube/config:~/.kube/config-prod

# Or merge configs
KUBECONFIG=config1:config2 kubectl config view --flatten > ~/.kube/config
```

## Tmux Configuration

The tmux setup includes:

- Custom prefix key (backtick)
- Vi-mode bindings
- Mouse support
- catppuccin theme
- System monitoring in status bar
- Plugin manager (tpm)

Install tmux plugins:

```bash
# Press prefix + I (backtick + Shift + i) to install plugins
```

## Troubleshooting

### Conflicts During Installation

If `dotfiles.sh` reports conflicts:

```bash
# Backup existing files
mv ~/.zshrc ~/.zshrc.backup

# Try again
./dotfiles.sh zsh
```

### ZSH Not Loading Modules

```bash
# Check if files exist
ls -la ~/.config/zsh/aliases/

# Source manually to see errors
source ~/.zshrc
```

### Completions Not Working

```bash
# Rebuild completion cache
rm ~/.zcompdump
autoload -U compinit && compinit
```

### mise Not Found

```bash
# Add mise to PATH
export PATH="$HOME/.local/bin:$PATH"

# Or install globally
curl https://mise.run | sh
```

## Updating

```bash
cd ~/dotfiles
git pull origin main
./dotfiles.sh --all

# Update mise-managed tools
mise upgrade
```

## Uninstalling

```bash
cd ~/dotfiles
stow -D zsh git tmux vim aws starship mise
```

## Acknowledgments

- [Dotfiles community](https://dotfiles.github.io/)
- [Starship](https://starship.rs/)
- [mise](https://mise.jdx.dev/) - Amazing asdf replacement
- [GNU Stow](https://www.gnu.org/software/stow/)
- All the amazing open-source tools that make this possible
