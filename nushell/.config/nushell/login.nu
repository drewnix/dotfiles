# Nushell Login Shell Configuration
# This file runs ONLY when nushell is launched as a login shell (nu -l or --login)
# Use for session-wide environment setup that should only initialize once

# SSH Agent Configuration
# Auto-start SSH agent if not already running
if not ("SSH_AUTH_SOCK" in $env) {
    let agent_sock = ($env.HOME | path join ".ssh" "agent.sock")

    # Check if agent socket exists and is valid
    if ($agent_sock | path exists) {
        $env.SSH_AUTH_SOCK = $agent_sock
    } else {
        # Start new SSH agent
        let agent_info = (^ssh-agent -s | lines | parse "{var}={value}; export {_};")

        for line in $agent_info {
            if $line.var == "SSH_AUTH_SOCK" {
                $env.SSH_AUTH_SOCK = $line.value
            } else if $line.var == "SSH_AGENT_PID" {
                $env.SSH_AGENT_PID = ($line.value | into int)
            }
        }
    }
}

# Display configuration (for X11 forwarding)
if not ("DISPLAY" in $env) {
    $env.DISPLAY = ":0"
}

# GPG Agent configuration
if (which gpg-agent | is-not-empty) {
    $env.GPG_TTY = (^tty | str trim)
}

# Session-wide environment variables
# Add any variables that should only be set once per login session here
