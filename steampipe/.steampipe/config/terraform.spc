# ╔══════════════════════════════════════════════════════════════╗
# ║ Steampipe Terraform Plugin Configuration                    ║
# ╚══════════════════════════════════════════════════════════════╝
#
# Terraform plugin for analyzing Terraform configuration files

# Default Terraform connection
connection "terraform" {
  plugin = "terraform"

  # Paths to search for Terraform files (.tf)
  # Supports glob patterns
  configuration_file_paths = [
    "~/terraform/**/*.tf",
    "~/projects/**/terraform/**/*.tf",
    "~/infra/**/*.tf"
  ]
}

# Example: Specific project connection
# connection "terraform_main" {
#   plugin = "terraform"
#   configuration_file_paths = ["~/projects/main-infra/**/*.tf"]
# }
