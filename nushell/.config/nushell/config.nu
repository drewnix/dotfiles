# Nushell Configuration File
# This is the main configuration file for nushell
# It sets up $env.config and loads autoload modules

# Core configuration settings
$env.config = {
    show_banner: false

    # Use emacs editing mode (standard readline keybindings)
    # Change to "vi" if you prefer vi keybindings
    edit_mode: emacs

    # Editor configuration
    buffer_editor: "vim"

    # History configuration - using SQLite for better performance
    history: {
        max_size: 1_000_000
        sync_on_enter: true
        file_format: "sqlite"
        isolation: true
    }

    # Completion configuration
    completions: {
        case_sensitive: false
        quick: true
        partial: true
        algorithm: "fuzzy"
    }

    # Shell integration for terminal features
    shell_integration: {
        osc2: true
        osc7: true
        osc8: true
        osc9_9: false
        osc133: true
        osc633: true
        reset_application_mode: false
    }
    use_ansi_coloring: true

    # Performance: render right prompt on last line
    render_right_prompt_on_last_line: false

    # Hooks for environment changes and prompt
    hooks: {
        pre_prompt: [
            # Update window title
            { ||
                if (term size).columns > 0 {
                    $"(ansi title)($env.PWD | path basename)(ansi reset)"
                }
            }
        ]
        pre_execution: []
        env_change: {
            PWD: []
        }
        display_output: "if (term size).columns > 0 { table } else { print }"
        command_not_found: []
    }

    # Keybindings
    keybindings: [
        {
            name: completion_menu
            modifier: none
            keycode: tab
            mode: [emacs vi_normal vi_insert]
            event: {
                until: [
                    { send: menu name: completion_menu }
                    { send: menunext }
                    { edit: complete }
                ]
            }
        }
        {
            name: history_menu
            modifier: control
            keycode: char_r
            mode: [emacs, vi_insert, vi_normal]
            event: { send: menu name: history_menu }
        }
        {
            name: help_menu
            modifier: none
            keycode: f1
            mode: [emacs, vi_insert, vi_normal]
            event: { send: menu name: help_menu }
        }
    ]

    # Menus for completion and history
    menus: [
        {
            name: completion_menu
            only_buffer_difference: false
            marker: "| "
            type: {
                layout: columnar
                columns: 4
                col_width: 20
                col_padding: 2
            }
            style: {
                text: green
                selected_text: green_reverse
                description_text: yellow
            }
        }
        {
            name: history_menu
            only_buffer_difference: true
            marker: "? "
            type: {
                layout: list
                page_size: 10
            }
            style: {
                text: green
                selected_text: green_reverse
                description_text: yellow
            }
        }
        {
            name: help_menu
            only_buffer_difference: true
            marker: "? "
            type: {
                layout: description
                columns: 4
                col_width: 20
                col_padding: 2
                selection_rows: 4
                description_rows: 10
            }
            style: {
                text: green
                selected_text: green_reverse
                description_text: yellow
            }
        }
    ]

    # Table display configuration
    table: {
        mode: rounded
        index_mode: always
        show_empty: true
        padding: { left: 1, right: 1 }
        trim: {
            methodology: wrapping
            wrapping_try_keep_words: true
            truncating_suffix: "..."
        }
        header_on_separator: false
    }

    # Datetime format
    datetime_format: {
        normal: '%Y-%m-%d %H:%M:%S'
        table: '%Y-%m-%d %H:%M:%S'
    }

    # Error style
    error_style: "fancy"

    # File size format - removed deprecated options in 0.108.0

    # Cursor shape for different modes
    cursor_shape: {
        emacs: line
        vi_insert: line
        vi_normal: block
    }

    # Color config - use default theme
    footer_mode: 25
    float_precision: 2
}

# Starship Prompt Setup
# This must be set early before autoload overrides it
$env.STARSHIP_SHELL = "nu"
$env.STARSHIP_SESSION_KEY = (random chars -l 16)
$env.PROMPT_INDICATOR = ""
$env.PROMPT_MULTILINE_INDICATOR = {|| ^starship prompt --continuation }

$env.PROMPT_COMMAND = {||
    let cmd_duration = ($env | get -o CMD_DURATION_MS | default 0)
    let last_exit = ($env | get -o LAST_EXIT_CODE | default 0)
    with-env {STARSHIP_SHELL: "nu"} {
        ^starship prompt --cmd-duration $cmd_duration $"--status=($last_exit)" --terminal-width (term size).columns
    }
}

$env.PROMPT_COMMAND_RIGHT = {||
    let cmd_duration = ($env | get -o CMD_DURATION_MS | default 0)
    let last_exit = ($env | get -o LAST_EXIT_CODE | default 0)
    with-env {STARSHIP_SHELL: "nu"} {
        ^starship prompt --right --cmd-duration $cmd_duration $"--status=($last_exit)" --terminal-width (term size).columns
    }
}

# Transient prompt - simplify prompt after command execution
$env.TRANSIENT_PROMPT_COMMAND = {|| "> " }
$env.TRANSIENT_PROMPT_COMMAND_RIGHT = {|| "" }

# Load standard library utilities
use std/util

# Autoload modules will be loaded automatically from ~/.config/nushell/autoload/
# The files are loaded in alphabetical order:
# - 01-environment.nu      (PATH, environment variables)
# - 02-integrations.nu     (starship, zoxide, carapace, direnv)
# - 10-aliases-general.nu  (general navigation and utilities)
# - 11-aliases-git.nu      (git workflows)
# - 12-aliases-k8s.nu      (kubernetes operations)
# - 13-aliases-terraform.nu (terraform and IaC)
# - 14-aliases-docker.nu   (docker and containers)
# - 15-aliases-aws.nu      (AWS CLI helpers)
# - 16-aliases-gcp.nu      (GCP/gcloud operations)
# - 20-completions.nu      (custom completions)
# - 99-local.nu            (machine-specific overrides)
