# ███████╗███████╗██╗  ██╗██████╗  ██████╗
# ╚══███╔╝██╔════╝██║  ██║██╔══██╗██╔════╝
#   ███╔╝ ███████╗███████║██████╔╝██║
#  ███╔╝  ╚════██║██╔══██║██╔══██╗██║
# ███████╗███████║██║  ██║██║  ██║╚██████╗
# ╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝
#
#  ██████████
# ╔█ author █ andrew <andrew@drewnix.dev>
# ║█ code   █ https://github.com/drewnix/dotfiles
# ║█ info   █ https://github.com/drewnix/dotfiles/blob/main/README.md
# ║██████████
# ╚═════════╝
#
# Modern, modular ZSH configuration for cloud-native development
# Optimized for: Kubernetes, Terraform, AWS, GCP, Docker, and more

# ╔══════════════════════════════════════════════════════════════╗
# ║ Secret & Company-Specific Configuration                      ║
# ╚══════════════════════════════════════════════════════════════╝

# Load secrets if they exist
if [ -f ~/.secrets ]; then
    source ~/.secrets
fi

# Load company-specific config if it exists
if [ -f "$HOME/.zshrc.spl" ]; then
  source $HOME/.zshrc.spl
fi

# ╔══════════════════════════════════════════════════════════════╗
# ║ SSH Key Management                                           ║
# ╚══════════════════════════════════════════════════════════════╝

# Auto-load SSH key on shell start
if [ -f ~/.ssh/id_rsa ]; then
  ssh-add -k ~/.ssh/id_rsa > /dev/null 2>&1
elif [ -f ~/.ssh/id_ed25519 ]; then
  ssh-add -k ~/.ssh/id_ed25519 > /dev/null 2>&1
fi

# ╔══════════════════════════════════════════════════════════════╗
# ║ Environment Variables & Path Setup                           ║
# ╚══════════════════════════════════════════════════════════════╝

# Load environment configuration
if [ -f ~/.config/zsh/env.zsh ]; then
  source ~/.config/zsh/env.zsh
fi

# ╔══════════════════════════════════════════════════════════════╗
# ║ Load Modular Aliases                                         ║
# ╚══════════════════════════════════════════════════════════════╝

# General utilities (ls, cd, etc.)
[ -f ~/.config/zsh/aliases/general.zsh ] && source ~/.config/zsh/aliases/general.zsh

# Git aliases and functions
[ -f ~/.config/zsh/aliases/git.zsh ] && source ~/.config/zsh/aliases/git.zsh

# Kubernetes (kubectl, helm, k9s, etc.)
[ -f ~/.config/zsh/aliases/kubernetes.zsh ] && source ~/.config/zsh/aliases/kubernetes.zsh

# Terraform & Terragrunt
[ -f ~/.config/zsh/aliases/terraform.zsh ] && source ~/.config/zsh/aliases/terraform.zsh

# AWS CLI
[ -f ~/.config/zsh/aliases/aws.zsh ] && source ~/.config/zsh/aliases/aws.zsh

# GCP/gcloud
[ -f ~/.config/zsh/aliases/gcp.zsh ] && source ~/.config/zsh/aliases/gcp.zsh

# Docker & containers
[ -f ~/.config/zsh/aliases/docker.zsh ] && source ~/.config/zsh/aliases/docker.zsh

# Yazi file manager
[ -f ~/.config/zsh/aliases/yazi.zsh ] && source ~/.config/zsh/aliases/yazi.zsh

# ╔══════════════════════════════════════════════════════════════╗
# ║ Starship Prompt                                              ║
# ╚══════════════════════════════════════════════════════════════╝

# Initialize Starship prompt (if installed)
if command -v starship &> /dev/null; then
  eval "$(starship init zsh)"
fi

# ╔══════════════════════════════════════════════════════════════╗
# ║ FZF Fuzzy Finder                                             ║
# ╚══════════════════════════════════════════════════════════════╝

# FZF configuration (if installed)
if command -v fzf &> /dev/null; then
  # Auto-completion
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

  # FZF default options
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --inline-info'

  # Use fd instead of find if available
  if command -v fd &> /dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  fi

  # FZF kubectl context switcher
  if command -v kubectl &> /dev/null; then
    kctx-fzf() {
      local context=$(kubectl config get-contexts -o name | fzf --height 40% --reverse)
      if [ -n "$context" ]; then
        kubectl config use-context "$context"
      fi
    }
  fi
fi

# ╔══════════════════════════════════════════════════════════════╗
# ║ zsh-autosuggestions                                          ║
# ╚══════════════════════════════════════════════════════════════╝

# Load zsh-autosuggestions (if installed)
if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
elif [ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
elif [ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# ╔══════════════════════════════════════════════════════════════╗
# ║ zsh-syntax-highlighting                                      ║
# ╚══════════════════════════════════════════════════════════════╝

# Load zsh-syntax-highlighting (must be last!)
if [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [ -f ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# ╔══════════════════════════════════════════════════════════════╗
# ║ Welcome Message                                              ║
# ╚══════════════════════════════════════════════════════════════╝

# Optional: Display a welcome message with system info
if [ -n "$PS1" ]; then
  # Only show on interactive shells, not in scripts or sub-shells
  if [ -z "$DOTFILES_LOADED" ]; then
    export DOTFILES_LOADED=1

    # Uncomment to show a welcome message on shell start
    # echo "Welcome to $(hostname)!"
    # echo "Loaded: Kubernetes, Terraform, AWS, GCP, Docker aliases"

    # Show current k8s context if configured
    if command -v kubectl &> /dev/null && kubectl config current-context &> /dev/null; then
      : # Silently check kubectl (starship will show this)
    fi
  fi
fi

# ╔══════════════════════════════════════════════════════════════╗
# ║ Local Customizations                                         ║
# ╚══════════════════════════════════════════════════════════════╝

# Load local customizations last (overrides everything)
# This file is not tracked in git - create it for environment-specific config
if [ -f "$HOME/.zshrc.local" ]; then
  source "$HOME/.zshrc.local"
fi

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
