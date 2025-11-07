# ╔══════════════════════════════════════════════════════════════╗
# ║ Steampipe Kubernetes Plugin Configuration                   ║
# ╚══════════════════════════════════════════════════════════════╝
#
# Kubernetes connections using contexts from ~/.kube/config

# Default Kubernetes connection - uses current context
connection "kubernetes" {
  plugin = "kubernetes"

  # Use current context from kubeconfig
  # Respects KUBECONFIG environment variable
}

# Example: Specific cluster connections
# Uncomment and customize for your clusters
# connection "k8s_prod" {
#   plugin = "kubernetes"
#   config_path = "~/.kube/config"
#   config_context = "production-cluster"
# }

# connection "k8s_staging" {
#   plugin = "kubernetes"
#   config_path = "~/.kube/config"
#   config_context = "staging-cluster"
# }

# Example: Multi-cluster aggregation
# Query across multiple clusters simultaneously
# connection "k8s_all" {
#   plugin = "kubernetes"
#   type = "aggregator"
#   connections = ["k8s_prod", "k8s_staging"]
# }
