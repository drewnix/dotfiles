# Nushell Environment File
# This file is now considered legacy - all configuration is in config.nu and autoload/
# Kept for backward compatibility but intentionally left minimal

# XDG Base Directory - Ensure nushell uses ~/.config instead of macOS-specific paths
# This must be set BEFORE nushell determines config paths
$env.XDG_CONFIG_HOME = ($env.XDG_CONFIG_HOME? | default ($env.HOME | path join ".config"))
$env.XDG_DATA_HOME = ($env.XDG_DATA_HOME? | default ($env.HOME | path join ".local" "share"))
$env.XDG_CACHE_HOME = ($env.XDG_CACHE_HOME? | default ($env.HOME | path join ".cache"))

# Set a placeholder prompt - config.nu will override this with Starship
$env.PROMPT_COMMAND = {|| "nushell> " }
$env.PROMPT_COMMAND_RIGHT = {|| "" }
