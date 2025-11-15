# Nushell Environment File
# This file is now considered legacy - all configuration is in config.nu and autoload/
# Kept for backward compatibility but intentionally left minimal

# Set a placeholder prompt - config.nu will override this with Starship
$env.PROMPT_COMMAND = {|| "nushell> " }
$env.PROMPT_COMMAND_RIGHT = {|| "" }
