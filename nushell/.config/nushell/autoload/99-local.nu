# Local Machine-Specific Configuration
# This file is for machine-specific overrides and should not be tracked in git
# Add this file to .gitignore if you want to keep local customizations

# ============================================================================
# Example: Machine-Specific Environment Variables
# ============================================================================

# Uncomment and customize these examples as needed:

# $env.CUSTOM_VAR = "value"
# $env.WORK_DIR = "~/projects/work"
# $env.PERSONAL_DIR = "~/projects/personal"

# ============================================================================
# Example: Machine-Specific Aliases
# ============================================================================

# Uncomment and add your own aliases:

# alias work = cd ~/projects/work
# alias personal = cd ~/projects/personal
# alias vpn = sudo openvpn --config ~/vpn/config.ovpn

# ============================================================================
# Example: Company-Specific Configuration
# ============================================================================

# If you have company-specific configurations (similar to .zshrc.spl):
# You can source them here or add them directly

# source ~/.config/nushell/company-config.nu

# ============================================================================
# Example: Custom Functions
# ============================================================================

# Add machine-specific custom functions here:

# def my-custom-command [] {
#     print "This is a machine-specific command"
# }

# ============================================================================
# Example: AWS/GCP Profile Shortcuts
# ============================================================================

# Create shortcuts for frequently used profiles/projects:

# def work-aws [] {
#     $env.AWS_PROFILE = "work-production"
#     print "Switched to work production AWS profile"
# }

# def personal-gcp [] {
#     gcloud config set project my-personal-project
# }

# ============================================================================
# Example: Kubernetes Context Shortcuts
# ============================================================================

# Quick switches to frequently used clusters:

# def k8s-prod [] {
#     kubectl config use-context production-cluster
# }

# def k8s-staging [] {
#     kubectl config use-context staging-cluster
# }

# ============================================================================
# Example: Custom PATH Additions
# ============================================================================

# Add machine-specific paths:

# use std/util "path add"
# path add "~/custom/bin"
# path add "~/company-tools/bin"

# ============================================================================
# Example: Secret/Token Management
# ============================================================================

# Load secrets from a separate file (make sure it's not in git!):
# if ("~/.secrets.nu" | path exists) {
#     source ~/.secrets.nu
# }

# Or set them directly (NOT RECOMMENDED - use a separate secrets file):
# $env.GITHUB_TOKEN = "your-token-here"
# $env.JIRA_API_TOKEN = "your-token-here"

# ============================================================================
# Example: Override Default Editor
# ============================================================================

# If this machine uses a different editor:
# $env.EDITOR = "code"
# $env.VISUAL = "code"

# ============================================================================
# Example: Machine-Specific Integrations
# ============================================================================

# If you have tools only on this machine:
# if (which some-tool | is-not-empty) {
#     alias st = some-tool
# }

# ============================================================================
# Notes
# ============================================================================

# This file loads LAST in the autoload sequence (99-local.nu)
# This means you can override anything defined in earlier files
# Perfect for machine-specific customizations without modifying main config files
