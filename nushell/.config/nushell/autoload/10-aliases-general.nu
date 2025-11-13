# General Aliases & Utility Functions
# Navigation, file operations, and system utilities

# ============================================================================
# Directory Navigation
# ============================================================================

alias .. = cd ..
alias ... = cd ../..
alias .... = cd ../../..
alias ..... = cd ../../../..

# Quick directory bookmarks
alias dl = cd ~/Downloads
alias dt = cd ~/Desktop
alias dev = cd ~/dev
alias docs = cd ~/Documents

# ============================================================================
# File Listing (nushell has built-in ls with structured output)
# ============================================================================

# Use eza if available for enhanced listings
if (which eza | is-not-empty) {
    alias l = eza -l --icons --group-directories-first --git
    alias la = eza -la --icons --group-directories-first --git
    alias ll = eza -l --icons --group-directories-first --git
    alias lsa = eza -lah --icons --group-directories-first --git
    alias lt = eza -l --sort=modified --icons --group-directories-first --git
    alias lsize = eza -l --sort=size --icons --group-directories-first --git
    alias tree = eza --tree --icons
    alias tree2 = eza --tree --level=2 --icons
    alias tree3 = eza --tree --level=3 --icons
} else {
    # Fallback to nushell's built-in ls with custom commands
    def l [] { ls | sort-by type name -i }
    def la [] { ls -a | sort-by type name -i }
    def ll [] { ls | sort-by type name -i }
    def lt [] { ls | sort-by modified -r }
    def lsize [] { ls | sort-by size -r }
}

# ============================================================================
# File Operations
# ============================================================================

# These are custom commands instead of aliases for better functionality
def mkcd [dir: string] {
    mkdir $dir
    cd $dir
}

def up [count: int = 1] {
    let path = (0..<$count | each { ".." } | str join "/")
    cd $path
}

def backup [file: string] {
    let timestamp = (date now | format date "%Y%m%d-%H%M%S")
    cp $file $"($file).backup-($timestamp)"
    print $"Backed up to ($file).backup-($timestamp)"
}

# ============================================================================
# Archive Extraction
# ============================================================================

def extract [file: string] {
    if not ($file | path exists) {
        print $"Error: '($file)' is not a valid file"
        return
    }

    match ($file | path parse | get extension) {
        "gz" | "tgz" => { ^tar -xzf $file }
        "bz2" | "tbz2" => { ^tar -xjf $file }
        "xz" | "txz" => { ^tar -xJf $file }
        "tar" => { ^tar -xf $file }
        "zip" => { ^unzip $file }
        "7z" => { ^7z x $file }
        "rar" => { ^unrar x $file }
        "Z" => { ^uncompress $file }
        _ => { print $"Error: Cannot extract '($file)' - unknown format" }
    }
}

# ============================================================================
# Process Management
# ============================================================================

def psg [pattern: string] {
    ps | where name =~ $pattern or command =~ $pattern
}

def psme [] {
    ps | where user == $env.USER
}

def killp [pattern: string] {
    let procs = (ps | where name =~ $pattern or command =~ $pattern)
    if ($procs | is-empty) {
        print $"No processes matching '($pattern)' found"
        return
    }

    print $"Found ($procs | length) processes:"
    print $procs

    # Kill each process
    $procs | each { |proc|
        print $"Killing ($proc.name) \(PID: ($proc.pid))"
        ^kill -9 $proc.pid
    }
}

# ============================================================================
# System Information
# ============================================================================

def myip [] {
    http get https://ifconfig.me
}

def publicip [] {
    print $"IPv4: (http get https://api.ipify.org)"
    print $"IPv6: (http get https://api6.ipify.org)"
}

def localip [] {
    if (sys host | get name) == "Linux" {
        ^ip addr show | lines | where $it =~ "inet " and $it !~ "127.0.0.1"
    } else if (sys host | get name) == "Darwin" {
        ^ifconfig | lines | where $it =~ "inet " and $it !~ "127.0.0.1"
    }
}

def listening [] {
    if (sys host | get name) == "Linux" {
        ^ss -tulanp | lines | where $it =~ "LISTEN"
    } else {
        ^lsof -i -P | lines | where $it =~ "LISTEN"
    }
}

# ============================================================================
# Disk Usage
# ============================================================================

def dirsize [dir: string = "."] {
    ^du -sh $dir | awk '{print $1}'
}

def largest [count: int = 10, dir: string = "."] {
    ^du -ah $dir | lines | sort-by -r | first $count
}

def countfiles [dir: string = "."] {
    ls -a $dir | where type == file | length
}

def diskspace [] {
    print "=== Disk Usage ==="
    ^df -h / | lines | last

    print "\n=== Largest directories in current path ==="
    ^du -sh */ | lines | sort-by -r | first 5
}

# ============================================================================
# Search Functions
# ============================================================================

def qfind [pattern: string] {
    if (which fd | is-not-empty) {
        ^fd $pattern
    } else {
        ^find . -iname $"*($pattern)*"
    }
}

def qgrep [pattern: string, file_pattern: string = "*"] {
    if (which rg | is-not-empty) {
        ^rg $pattern
    } else {
        ^grep -r $pattern --include=$file_pattern .
    }
}

# ============================================================================
# Quick Utilities
# ============================================================================

# JSON pretty print
def pjson [file?: string] {
    if $file == null {
        from json | to json --indent 2
    } else {
        open $file | to json --indent 2
    }
}

# YAML pretty print
def pyaml [file?: string] {
    if (which yq | is-empty) {
        print "Error: yq not installed"
        return
    }

    if $file == null {
        ^yq eval '.' -
    } else {
        ^yq eval '.' $file
    }
}

# Calculator
def calc [...expr: string] {
    let expression = ($expr | str join " ")
    ^echo $expression | ^bc -l
}

# Generate random password
def genpass [length: int = 16] {
    ^tr -dc 'A-Za-z0-9!@#$%^&*' < /dev/urandom | ^head -c $length
    print ""
}

# Timer/stopwatch
def timer [seconds: int = 60] {
    print $"Timer set for ($seconds) seconds..."
    sleep ($seconds * 1sec)
    print "Time's up!"
}

# ============================================================================
# Shell Configuration
# ============================================================================

def reload [] {
    print "Reloading nushell configuration..."
    nu
}

def editrc [] {
    ^$env.EDITOR ($nu.config-path)
}

def nushrc [] {
    ^$env.EDITOR ($nu.config-path)
}

# Quick edits
def vimrc [] {
    ^$env.EDITOR ~/.vimrc
}

def hosts [] {
    ^sudo $env.EDITOR /etc/hosts
}

def notes [] {
    ^$env.EDITOR ~/notes.md
}

# ============================================================================
# tmux Aliases
# ============================================================================

alias t = tmux
alias ta = tmux attach
alias tls = tmux ls
alias tat = tmux attach -t
alias tns = tmux new-session -s

# ============================================================================
# Quick Servers
# ============================================================================

alias serve = python3 -m http.server
alias serve8000 = python3 -m http.server 8000

# ============================================================================
# Clipboard (cross-platform)
# ============================================================================

if (which xclip | is-not-empty) {
    alias clip = xclip -selection clipboard
    alias clipout = xclip -selection clipboard -o
} else if (which pbcopy | is-not-empty) {
    alias clip = pbcopy
    alias clipout = pbpaste
}

# ============================================================================
# Enhanced cat with bat
# ============================================================================

if (which bat | is-not-empty) {
    alias cat = bat
    alias catn = bat --style=plain
}

# ============================================================================
# Weather
# ============================================================================

def weather [location?: string] {
    if $location == null {
        http get https://wttr.in
    } else {
        http get $"https://wttr.in/($location)"
    }
}

# ============================================================================
# System Information Summary
# ============================================================================

def sysinfo [] {
    print "=== System Information ==="
    print $"Hostname: (sys host | get hostname)"
    print $"OS: (sys host | get name) (sys host | get kernel_version)"
    print $"Uptime: (sys host | get uptime)"

    print "\n=== CPU ==="
    print $"CPUs: (sys cpu | length)"

    print "\n=== Memory ==="
    let mem = (sys mem)
    let total = ($mem.total / 1GB | math round -p 2)
    let free = ($mem.free / 1GB | math round -p 2)
    let used = ($total - $free | math round -p 2)
    print $"Total: ($total) GB"
    print $"Used: ($used) GB"
    print $"Free: ($free) GB"

    print "\n=== Disk ==="
    ^df -h / | lines | last
}

# ============================================================================
# Path Management
# ============================================================================

def path-show [] {
    $env.PATH | each { |p| print $p }
}

# ============================================================================
# History Statistics
# ============================================================================

def histats [] {
    history
    | get command
    | split column " "
    | get column1
    | uniq -c
    | sort-by count -r
    | first 20
}

def histop [count: int = 20] {
    print $"=== Top ($count) most used commands ==="
    history
    | get command
    | split column " "
    | get column1
    | uniq -c
    | sort-by count -r
    | first $count
}
