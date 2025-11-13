# Environment Configuration
# PATH management, library directories, and core environment variables

# Load standard library path utilities
use std/util "path add"

# Core Environment Variables
$env.EDITOR = "vim"
$env.VISUAL = "vim"

# XDG Base Directory Specification
$env.XDG_CONFIG_HOME = ($env.HOME | path join ".config")
$env.XDG_DATA_HOME = ($env.HOME | path join ".local" "share")
$env.XDG_CACHE_HOME = ($env.HOME | path join ".cache")

# Nushell library and plugin directories
$env.NU_LIB_DIRS = [
    ($nu.default-config-dir | path join "scripts")
    ($nu.default-config-dir | path join "modules")
]

# PATH Management
# Add local binaries
path add ($env.HOME | path join ".local" "bin")

# Add cargo binaries if Rust is installed
if ($env.HOME | path join ".cargo" "bin" | path exists) {
    path add ($env.HOME | path join ".cargo" "bin")
}

# Add Go binaries if Go is installed
if ("GOPATH" in $env) {
    path add ($env.GOPATH | path join "bin")
} else if ($env.HOME | path join "go" "bin" | path exists) {
    path add ($env.HOME | path join "go" "bin")
}

# Add krew (kubectl plugin manager) to PATH
let krew_bin = ($env.HOME | path join ".krew" "bin")
if ($krew_bin | path exists) {
    path add $krew_bin
}

# Cloud Provider CLI Configuration

# AWS Configuration
$env.AWS_PAGER = ""  # Disable pager for AWS CLI
$env.AWS_DEFAULT_OUTPUT = "json"

# GCP Configuration
$env.CLOUDSDK_PYTHON_SITEPACKAGES = "1"

# Kubernetes Configuration
# Use default kubeconfig location, can be overridden in 99-local.nu
if not ("KUBECONFIG" in $env) {
    $env.KUBECONFIG = ($env.HOME | path join ".kube" "config")
}

# Docker Configuration
$env.DOCKER_BUILDKIT = "1"
$env.COMPOSE_DOCKER_CLI_BUILD = "1"

# Terraform Configuration
$env.TF_PLUGIN_CACHE_DIR = ($env.HOME | path join ".terraform.d" "plugin-cache")

# Security Tools Configuration
# Trivy cache directory
$env.TRIVY_CACHE_DIR = ($env.XDG_CACHE_HOME | path join "trivy")

# Tool-specific Configuration

# FZF Configuration (if using fzf)
$env.FZF_DEFAULT_OPTS = "--height 40% --layout=reverse --border"

# Less configuration
$env.LESS = "-R"
$env.LESSHISTFILE = "-"  # Don't create less history file

# Bat configuration (if installed)
if (which bat | is-not-empty) {
    $env.BAT_THEME = "TwoDark"
    $env.BAT_STYLE = "numbers,changes,header"
}

# Language-specific environment variables

# Python
$env.PYTHONDONTWRITEBYTECODE = "1"  # Don't create .pyc files

# Node.js
if ($env.HOME | path join ".npm-global" | path exists) {
    path add ($env.HOME | path join ".npm-global" "bin")
}

# Pager configuration
$env.PAGER = "less"

# Man page colors (for less)
$env.MANPAGER = "less -R --use-color -Dd+r -Du+b"

# Colorize ls output (if using GNU coreutils)
if (sys host | get name) == "Linux" {
    $env.LS_COLORS = (^dircolors -b | lines | first | parse "LS_COLORS='{colors}';" | get colors.0)
}

# History configuration (complementing config.nu settings)
# These environment variables work with nushell's history system
$env.HISTCONTROL = "ignoredups:ignorespace"

# Set locale (adjust as needed)
$env.LANG = "en_US.UTF-8"
$env.LC_ALL = "en_US.UTF-8"

# Mise (version manager) configuration
# Note: mise activation happens in 02-integrations.nu
if ("MISE_DATA_DIR" not-in $env) {
    $env.MISE_DATA_DIR = ($env.XDG_DATA_HOME | path join "mise")
}
if ("MISE_CONFIG_DIR" not-in $env) {
    $env.MISE_CONFIG_DIR = ($env.XDG_CONFIG_HOME | path join "mise")
}