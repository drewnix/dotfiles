# ╔══════════════════════════════════════════════════════════════╗
# ║ Steampipe AWS Plugin Configuration                          ║
# ╚══════════════════════════════════════════════════════════════╝
#
# AWS connections using profiles from ~/.aws/config
# Uses aws-vault for secure credential management

# Default AWS connection - uses default AWS credential chain
# This respects AWS_PROFILE, AWS_ACCESS_KEY_ID, ~/.aws/credentials, etc.
connection "aws" {
  plugin = "aws"

  # Regions to query (empty = all regions)
  # Uncomment to limit to specific regions for faster queries
  # regions = ["us-east-1", "us-west-2"]
}

# Example: Production environment connection
# Uncomment and customize for your AWS accounts
# connection "aws_prod" {
#   plugin = "aws"
#   profile = "production"
#   regions = ["us-east-1", "us-west-2", "eu-west-1"]
# }

# Example: Development environment connection
# connection "aws_dev" {
#   plugin = "aws"
#   profile = "development"
#   regions = ["us-east-1"]
# }

# Example: Multi-account aggregation
# Query across multiple accounts simultaneously
# connection "aws_all" {
#   plugin = "aws"
#   type = "aggregator"
#   connections = ["aws_prod", "aws_dev"]
# }
