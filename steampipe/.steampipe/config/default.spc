# ╔══════════════════════════════════════════════════════════════╗
# ║ Steampipe Default Configuration                             ║
# ╚══════════════════════════════════════════════════════════════╝
#
# General Steampipe options and settings

options "general" {
  # Log level: trace, debug, info, warn, error
  log_level = "warn"

  # Maximum memory to use for query execution (MB)
  memory_max_mb = 1024

  # Update check - set to false to disable update checks
  update_check = true

  # Telemetry: none, info
  telemetry = "info"
}

options "database" {
  # Enable query result caching
  cache = true

  # Cache TTL in seconds (default 300)
  cache_max_ttl = 900

  # Maximum cache size in MB
  cache_max_size_mb = 1024

  # Database port (default 9193)
  # port = 9193

  # Listen address: local or network
  listen = "local"

  # Search path prefix for convenience
  search_path_prefix = "aws,gcp,kubernetes,github,terraform,docker"

  # Service start timeout in seconds
  start_timeout = 30
}
