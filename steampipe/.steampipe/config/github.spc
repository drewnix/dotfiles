# ╔══════════════════════════════════════════════════════════════╗
# ║ Steampipe GitHub Plugin Configuration                       ║
# ╚══════════════════════════════════════════════════════════════╝
#
# GitHub connection using personal access token
# Requires GITHUB_TOKEN environment variable or token parameter

# Default GitHub connection
connection "github" {
  plugin = "github"

  # Uses GITHUB_TOKEN environment variable
  # Create token at: https://github.com/settings/tokens
  # Required scopes: repo, read:org, read:user, read:project

  # Uncomment to specify token directly (not recommended - use env var)
  # token = "ghp_your_token_here"
}

# Example: GitHub Enterprise connection
# connection "github_enterprise" {
#   plugin = "github"
#   base_url = "https://github.company.com/api/v3"
#   token = env("GITHUB_ENTERPRISE_TOKEN")
# }
