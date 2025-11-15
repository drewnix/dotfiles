# Third-Party Tool Integrations
# Starship, zoxide, carapace, direnv, and mise integrations

# Starship Prompt
# Starship is now configured in config.nu (loaded before autoload)
# This file just ensures STARSHIP_SHELL environment variable is set correctly
if (which starship | is-not-empty) {
    # Always set STARSHIP_SHELL to override any inherited value from parent shell
    $env.STARSHIP_SHELL = "nu"
}

# Zoxide - Smart directory jumping
# Zoxide should be initialized via vendor autoload during bootstrap
# The integration is generated with: zoxide init nushell
if (which zoxide | is-not-empty) {
    let zoxide_vendor = ($nu.default-config-dir | path join ".." ".." "share" "nushell" "vendor" "autoload" "zoxide.nu")
    if not ($zoxide_vendor | path exists) {
        # Fallback: create basic z alias
        def --env z [...args: string] {
            let result = (^zoxide query ...$args)
            cd $result
        }

        def --env zi [] {
            let result = (^zoxide query -i)
            cd $result
        }
    }
}

# Carapace - Advanced completions
# Carapace should be initialized via vendor autoload during bootstrap
# The integration is generated with: carapace _carapace nushell
if (which carapace | is-not-empty) {
    let carapace_vendor = ($nu.default-config-dir | path join ".." ".." "share" "nushell" "vendor" "autoload" "carapace.nu")
    if not ($carapace_vendor | path exists) {
        # Fallback: set up basic carapace completer
        $env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'

        # This will be enhanced in 20-completions.nu with custom completers
        let carapace_completer = {|spans: list<string>|
            carapace $spans.0 nushell ...$spans
            | from json
            | if ($in | default [] | where value =~ '^-.*ERR$' | is-empty) { $in } else { null }
        }

        $env.config.completions.external = {
            enable: true
            max_results: 100
            completer: $carapace_completer
        }
    }
}

# Direnv - Per-directory environments
# Automatically load/unload environment variables based on directory
if (which direnv | is-not-empty) {
    $env.config.hooks.pre_prompt = ($env.config.hooks.pre_prompt | append {||
        if (which direnv | is-empty) {
            return
        }

        direnv export json
        | from json
        | default {}
        | load-env

        # Handle PATH conversion if needed
        if 'ENV_CONVERSIONS' in $env and 'PATH' in $env.ENV_CONVERSIONS {
            $env.PATH = do $env.ENV_CONVERSIONS.PATH.from_string $env.PATH
        }
    })
}

# Mise - Version manager (replaces asdf, much faster)
# Activate mise for automatic version switching
if (which mise | is-not-empty) {
    # Mise activation - this makes mise shims available
    $env.PATH = ($env.PATH | prepend ($env.HOME | path join ".local" "share" "mise" "shims"))

    # Hook for automatic version switching when changing directories
    $env.config.hooks.env_change.PWD = ($env.config.hooks.env_change.PWD | append {|before, after|
        if (which mise | is-empty) {
            return
        }

        # Run mise hook to activate tools for current directory
        mise hook-env -s nu
        | lines
        | each { |line|
            if ($line | str starts-with '$env.') {
                # Parse and execute environment variable assignments
                let parts = ($line | parse '$env.{var} = {value}')
                if ($parts | is-not-empty) {
                    let var = ($parts | get var.0)
                    let value = ($parts | get value.0 | str trim --char '"')
                    load-env { $var: $value }
                }
            }
        }
    })
}

# FZF Integration (if installed)
# Enhanced fuzzy finding for various operations
if (which fzf | is-not-empty) {
    # Helper for FZF-based file selection
    def fzf-files [] {
        ^fzf --preview 'bat --color=always --style=numbers {}' --preview-window right:60%
    }

    # Helper for FZF-based directory selection
    def fzf-dirs [] {
        fd --type d | ^fzf --preview 'ls -la {}'
    }
}

# Atuin - Shell history sync and search (if installed)
# Provides SQLite-backed history with sync capabilities
if (which atuin | is-not-empty) {
    # Atuin can be initialized here if needed
    # Most users will want to set this up separately with: atuin init nu
}

# Navi - Interactive cheatsheet tool (if installed)
if (which navi | is-not-empty) {
    # Navi provides interactive cheatsheets
    # Can be activated with custom keybindings in config.nu if desired
}
