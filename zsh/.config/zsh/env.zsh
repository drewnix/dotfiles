# ╔══════════════════════════════════════════════════════════════╗
# ║ Environment Variables & Path Configuration                   ║
# ╚══════════════════════════════════════════════════════════════╝

# Go Programming
export GOPATH=$HOME/go
export GOPRIVATE="cd.splunkdev.com"
export GOPROXY="https://repo.splunk.com/artifactory/go | https://proxy.golang.org | direct"

# Splunk (if applicable)
export SPLUNK_HOME=/Applications/Splunk

# Local bin paths
export PATH=~/.local/bin:$PATH:$GOPATH/bin

# Homebrew (macOS/Linux)
if [ -d "/opt/homebrew/bin" ]; then
  export PATH="/opt/homebrew/bin:$PATH"
elif [ -d "/home/linuxbrew/.linuxbrew/bin" ]; then
  export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
fi

# Rust/Cargo
if [ -d "$HOME/.cargo/bin" ]; then
  export PATH="$HOME/.cargo/bin:$PATH"
fi

# mise version manager (replaces asdf, much faster)
if command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
elif [ -d "$HOME/.local/bin/mise" ]; then
  eval "$($HOME/.local/bin/mise activate zsh)"
fi

# Default editor
export EDITOR="vim"
export VISUAL="vim"

# Better history
export HISTFILE=~/.zsh_history
export HISTSIZE=50000
export SAVEHIST=50000
export HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups
setopt extended_history      # Record timestamp with each command

# Case-insensitive completion
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select

# kubectl completion
if command -v kubectl &> /dev/null; then
  source <(kubectl completion zsh)
fi

# terraform completion
if command -v terraform &> /dev/null; then
  autoload -U +X bashcompinit && bashcompinit
  complete -o nospace -C /usr/bin/terraform terraform 2>/dev/null || complete -o nospace -C $(which terraform) terraform
fi

# AWS CLI completion
if command -v aws_completer &> /dev/null; then
  complete -C aws_completer aws
fi

# gcloud completion
if [ -f "$HOME/.local/share/google-cloud-sdk/completion.zsh.inc" ]; then
  source "$HOME/.local/share/google-cloud-sdk/completion.zsh.inc"
fi
