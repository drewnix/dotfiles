# ╔══════════════════════════════════════════════════════════════╗
# ║ Steampipe Docker Plugin Configuration                       ║
# ╚══════════════════════════════════════════════════════════════╝
#
# Docker plugin for querying local Docker daemon

# Default Docker connection - uses local Docker socket
connection "docker" {
  plugin = "docker"

  # Uses default Docker socket at unix:///var/run/docker.sock
  # Respects DOCKER_HOST environment variable
}

# Example: Remote Docker connection
# connection "docker_remote" {
#   plugin = "docker"
#   host = "tcp://remote-host:2376"
#   cert_path = "~/.docker/certs"
# }
