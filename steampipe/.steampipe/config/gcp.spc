# ╔══════════════════════════════════════════════════════════════╗
# ║ Steampipe GCP Plugin Configuration                          ║
# ╚══════════════════════════════════════════════════════════════╝
#
# GCP connections using gcloud configuration

# Default GCP connection - uses default credentials
connection "gcp" {
  plugin = "gcp"

  # Use default GCP credential chain
  # Respects GOOGLE_APPLICATION_CREDENTIALS, gcloud config, etc.

  # Uncomment to specify a project
  # project = "my-project-id"
}

# Example: Specific project connections
# Uncomment and customize for your GCP projects
# connection "gcp_prod" {
#   plugin = "gcp"
#   project = "my-prod-project"
#   credentials = "~/.config/gcloud/application_default_credentials.json"
# }

# connection "gcp_dev" {
#   plugin = "gcp"
#   project = "my-dev-project"
# }

# Example: Multi-project aggregation
# Query across multiple projects simultaneously
# connection "gcp_all" {
#   plugin = "gcp"
#   type = "aggregator"
#   connections = ["gcp_prod", "gcp_dev"]
# }
