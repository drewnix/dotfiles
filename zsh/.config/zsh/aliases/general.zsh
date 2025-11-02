# ╔══════════════════════════════════════════════════════════════╗
# ║ General Aliases & Utility Functions                          ║
# ╚══════════════════════════════════════════════════════════════╝

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# ls aliases (with color support)
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
  alias ls='ls -G'
  alias l='ls -lFhG'
  alias la='ls -lAFhG'
  alias ll='ls -lFhG'
else
  # Linux
  alias ls='ls --color=auto'
  alias l='ls -lFh --color=auto'
  alias la='ls -lAFh --color=auto'
  alias ll='ls -lFh --color=auto'
fi

alias lsa='ls -lah'
alias lt='ls -lhtr'  # sort by time, newest last
alias lsize='ls -lhS' # sort by size

# Grep with color
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# File operations
alias cp='cp -i'    # confirm before overwrite
alias mv='mv -i'    # confirm before overwrite
alias rm='rm -i'    # confirm before delete
alias mkdir='mkdir -p' # create parent directories

# Find aliases
alias fd='find . -type d -name'
alias ff='find . -type f -name'

# Process management
alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'
alias psme='ps aux | grep $USER'

# System info
alias ports='netstat -tulanp'
alias listening='lsof -i -P | grep LISTEN'
alias myip='curl -s ifconfig.me'
alias localip='ip addr show | grep inet | grep -v inet6 | grep -v 127.0.0.1'

# Disk usage
alias du='du -h'
alias df='df -h'
alias duh='du -h --max-depth=1 | sort -h'
alias dus='du -sh * | sort -h'

# Archives
alias untar='tar -xvf'
alias targz='tar -czvf'
alias tarxz='tar -xvf'

# Quick edits
alias zshrc='$EDITOR ~/.zshrc'
alias vimrc='$EDITOR ~/.vimrc'
alias hosts='sudo $EDITOR /etc/hosts'

# Ranger file manager
alias r='ranger'
alias rgr='ranger'

# Terminal multiplexer
alias t='tmux'
alias ta='tmux attach'
alias tls='tmux ls'
alias tat='tmux attach -t'
alias tns='tmux new-session -s'

# Quick python server
alias serve='python3 -m http.server'
alias serve8000='python3 -m http.server 8000'

# JSON pretty print
alias json='python3 -m json.tool'

# Quick notes
alias notes='$EDITOR ~/notes.md'

# Weather
alias weather='curl wttr.in'

# Quick directory bookmarks
alias dl='cd ~/Downloads'
alias dt='cd ~/Desktop'
alias dev='cd ~/dev'
alias docs='cd ~/Documents'

# Clipboard (platform-specific)
if command -v xclip &> /dev/null; then
  alias clip='xclip -selection clipboard'
  alias clipout='xclip -selection clipboard -o'
elif command -v pbcopy &> /dev/null; then
  alias clip='pbcopy'
  alias clipout='pbpaste'
fi

# Colorize cat output with bat (if installed)
if command -v bat &> /dev/null; then
  alias cat='bat'
  alias catn='bat --style=plain'
fi

# Better find with fd (if installed)
if command -v fd &> /dev/null; then
  alias find='fd'
fi

# eza (modern ls replacement) - if installed
if command -v eza &> /dev/null; then
  # Basic ls replacements with icons and group directories first
  alias ls='eza --icons --group-directories-first'
  alias l='eza -l --icons --group-directories-first --git'
  alias la='eza -la --icons --group-directories-first --git'
  alias ll='eza -l --icons --group-directories-first --git'
  alias lsa='eza -lah --icons --group-directories-first --git'

  # Time-based listings
  alias lt='eza -l --sort=modified --icons --group-directories-first --git'
  alias lm='eza -l --sort=modified --icons --group-directories-first --git'
  alias lr='eza -lR --icons --group-directories-first'

  # Size sorting
  alias lsize='eza -l --sort=size --icons --group-directories-first --git'

  # Tree views
  alias tree='eza --tree --icons'
  alias tree2='eza --tree --level=2 --icons'
  alias tree3='eza --tree --level=3 --icons'

  # Git-focused view
  alias lg='eza -l --git --git-ignore --icons --group-directories-first'
fi

# ╔══════════════════════════════════════════════════════════════╗
# ║ Utility Functions                                            ║
# ╚══════════════════════════════════════════════════════════════╝

# Make directory and cd into it
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Go up N directories
up() {
  local count=${1:-1}
  local path=""
  for ((i=0; i<count; i++)); do
    path="../$path"
  done
  cd $path
}

# Extract any archive
extract() {
  if [ -z "$1" ]; then
    echo "Usage: extract <archive-file>"
    return 1
  fi

  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2)   tar xjf "$1"     ;;
      *.tar.gz)    tar xzf "$1"     ;;
      *.tar.xz)    tar xJf "$1"     ;;
      *.bz2)       bunzip2 "$1"     ;;
      *.rar)       unrar x "$1"     ;;
      *.gz)        gunzip "$1"      ;;
      *.tar)       tar xf "$1"      ;;
      *.tbz2)      tar xjf "$1"     ;;
      *.tgz)       tar xzf "$1"     ;;
      *.zip)       unzip "$1"       ;;
      *.Z)         uncompress "$1"  ;;
      *.7z)        7z x "$1"        ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Find and kill process by name
killp() {
  if [ -z "$1" ]; then
    echo "Usage: killp <process-name>"
    return 1
  fi
  ps aux | grep "$1" | grep -v grep | awk '{print $2}' | xargs kill -9
}

# Quick backup of file
backup() {
  if [ -z "$1" ]; then
    echo "Usage: backup <file>"
    return 1
  fi
  cp "$1" "$1.backup-$(date +%Y%m%d-%H%M%S)"
}

# Quick find in current directory
qfind() {
  if [ -z "$1" ]; then
    echo "Usage: qfind <pattern>"
    return 1
  fi
  find . -iname "*$1*" 2>/dev/null
}

# Quick grep in current directory
qgrep() {
  if [ -z "$1" ]; then
    echo "Usage: qgrep <pattern> [file-pattern]"
    return 1
  fi
  local file_pattern="${2:-*}"
  grep -r "$1" --include="$file_pattern" . 2>/dev/null
}

# Show directory size
dirsize() {
  du -sh "${1:-.}" | cut -f1
}

# Show largest files in directory
largest() {
  local count="${1:-10}"
  du -ah "${2:-.}" | sort -rh | head -n "$count"
}

# Count files in directory
countfiles() {
  find "${1:-.}" -type f | wc -l
}

# Get file/folder size
size() {
  du -sh "$@"
}

# Show PATH in readable format
path() {
  echo $PATH | tr ':' '\n'
}

# Reload shell configuration
reload() {
  source ~/.zshrc
  echo "Shell configuration reloaded!"
}

# Edit shell configuration
editrc() {
  $EDITOR ~/.zshrc
}

# Quick calculator
calc() {
  echo "$@" | bc -l
}

# Generate random password
genpass() {
  local length="${1:-16}"
  LC_ALL=C tr -dc 'A-Za-z0-9!@#$%^&*' < /dev/urandom | head -c "$length"
  echo
}

# Show command history stats
histats() {
  history | awk '{print $2}' | sort | uniq -c | sort -rn | head -20
}

# Quick timer/stopwatch
timer() {
  local seconds=${1:-60}
  echo "Timer set for $seconds seconds..."
  sleep "$seconds"
  echo "Time's up!"
  # Beep if terminal supports it
  echo -e '\a'
}

# Pretty-print JSON file or stdin
pjson() {
  if [ -z "$1" ]; then
    python3 -m json.tool
  else
    cat "$1" | python3 -m json.tool
  fi
}

# Pretty-print YAML (requires yq)
if command -v yq &> /dev/null; then
  pyaml() {
    if [ -z "$1" ]; then
      yq eval '.' -
    else
      yq eval '.' "$1"
    fi
  }
fi

# Get public IP
publicip() {
  echo "IPv4: $(curl -4 -s ifconfig.me)"
  echo "IPv6: $(curl -6 -s ifconfig.me 2>/dev/null || echo 'Not available')"
}

# Quick disk space check
diskspace() {
  echo "Disk Usage:"
  df -h / | tail -1 | awk '{print "Root: " $3 " / " $2 " (" $5 " used)"}'
  echo "\nLargest directories in current path:"
  du -sh */ 2>/dev/null | sort -rh | head -5
}

# System resource summary
sysinfo() {
  echo "=== System Information ==="
  echo "Hostname: $(hostname)"
  echo "OS: $(uname -s) $(uname -r)"
  echo "Uptime: $(uptime | awk '{print $3,$4}' | sed 's/,//')"
  echo "\n=== CPU ==="
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sysctl -n machdep.cpu.brand_string
  else
    grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs
  fi
  echo "\n=== Memory ==="
  free -h 2>/dev/null || vm_stat | grep -E "(Pages free|Pages active|Pages inactive|Pages wired down)"
  echo "\n=== Disk ==="
  df -h / | tail -1
}

# ╔══════════════════════════════════════════════════════════════╗
# ║ History Management Functions                                 ║
# ╚══════════════════════════════════════════════════════════════╝

# Search history with timestamps
histime() {
  if [ -z "$1" ]; then
    echo "Usage: histime <search-pattern>"
    echo "Example: histime kubectl"
    return 1
  fi
  fc -li 1 | grep -i "$1"
}

# Show history for today
histoday() {
  local today=$(date +%Y-%m-%d)
  echo "=== Commands run today ($today) ==="
  fc -li 1 | awk -v d="$today" '$2 == d'
}

# Show history for specific date
histdate() {
  if [ -z "$1" ]; then
    echo "Usage: histdate <YYYY-MM-DD>"
    echo "Example: histdate 2024-10-15"
    return 1
  fi
  echo "=== Commands run on $1 ==="
  fc -li 1 | awk -v d="$1" '$2 == d'
}

# Show history for date range
histrange() {
  if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: histrange <start-date> <end-date>"
    echo "Example: histrange 2024-10-15 2024-10-18"
    return 1
  fi
  echo "=== Commands run between $1 and $2 ==="
  fc -li 1 | awk -v start="$1" -v end="$2" '$2 >= start && $2 <= end'
}

# Audit: show all potentially destructive commands with timestamps
histaudit() {
  echo "=== Potentially destructive commands ==="
  echo "Showing: delete, destroy, rm, remove, terminate, drop\n"
  fc -li 1 | grep -E "delete|destroy|rm |remove|terminate|drop "
}

# Show most used commands (with extended stats)
histop() {
  local count="${1:-20}"
  echo "=== Top $count most used commands ==="
  fc -li 1 | awk '{CMD[$4]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | \
    grep -v "./" | column -c3 -s " " -t | sort -nr | nl | head -n "$count"
}

# Export history to file
histexport() {
  local output="${1:-history_export_$(date +%Y%m%d_%H%M%S).txt}"
  echo "Exporting history to: $output"
  fc -li 1 > "$output"
  echo "Exported $(wc -l < "$output") commands"
}
