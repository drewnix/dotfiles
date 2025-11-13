# Docker & Container Aliases
# Docker, docker-compose, and container management

# ============================================================================
# Core Docker Commands
# ============================================================================

alias d = docker
alias di = docker images
alias dps = docker ps
alias dpsa = docker ps -a
alias drm = docker rm
alias drmi = docker rmi
alias drun = docker run
alias dexec = docker exec -it
alias dlogs = docker logs
alias dlogsf = docker logs -f
alias dstop = docker stop
alias dstart = docker start
alias drestart = docker restart
alias dinspect = docker inspect
alias dpull = docker pull
alias dpush = docker push
alias dbuild = docker build
alias dtag = docker tag

# ============================================================================
# Docker System
# ============================================================================

alias dinfo = docker info
alias dversion = docker version
alias dsystem = docker system
alias ddf = docker system df
alias dprune = docker system prune
alias dprunea = docker system prune -a
alias dprunev = docker system prune --volumes

# ============================================================================
# Docker Compose (hyphenated)
# ============================================================================

alias dc = docker-compose
alias dcu = docker-compose up
alias dcud = docker-compose up -d
alias dcd = docker-compose down
alias dcb = docker-compose build
alias dcr = docker-compose run
alias dce = docker-compose exec
alias dclogs = docker-compose logs
alias dclogsf = docker-compose logs -f
alias dcps = docker-compose ps
alias dcrestart = docker-compose restart
alias dcstop = docker-compose stop
alias dcstart = docker-compose start
alias dcpull = docker-compose pull

# ============================================================================
# Docker Compose v2 (no hyphen)
# ============================================================================

alias dkc = docker compose
alias dkcu = docker compose up
alias dkcud = docker compose up -d
alias dkcd = docker compose down
alias dkcb = docker compose build
alias dkcr = docker compose run
alias dkce = docker compose exec
alias dkclogs = docker compose logs
alias dkclogsf = docker compose logs -f
alias dkcps = docker compose ps
alias dkcrestart = docker compose restart

# ============================================================================
# Docker Networks
# ============================================================================

alias dnet = docker network
alias dnetls = docker network ls
alias dnetrm = docker network rm
alias dnetinspect = docker network inspect

# ============================================================================
# Docker Volumes
# ============================================================================

alias dvol = docker volume
alias dvolls = docker volume ls
alias dvolrm = docker volume rm
alias dvolinspect = docker volume inspect
alias dvolprune = docker volume prune

# ============================================================================
# Container Registry
# ============================================================================

alias dcr-login = docker login
alias dcr-logout = docker logout

# ============================================================================
# Podman (Docker alternative) - if installed
# ============================================================================

if (which podman | is-not-empty) {
    alias p = podman
    alias pi = podman images
    alias pps = podman ps
    alias ppsa = podman ps -a
    alias prm = podman rm
    alias prmi = podman rmi
    alias prun = podman run
    alias pexec = podman exec -it
    alias plogs = podman logs
    alias pstop = podman stop
    alias pstart = podman start
}

# ============================================================================
# Docker Helper Functions
# ============================================================================

# Stop all running containers
def dstopall [] {
    let containers = (docker ps -q | lines)

    if ($containers | is-empty) {
        print "No running containers"
    } else {
        $containers | each { |c| docker stop $c }
        print "Stopped all running containers"
    }
}

# Remove all stopped containers
def drmall [] {
    let containers = (docker ps -aq -f status=exited | lines)

    if ($containers | is-empty) {
        print "No stopped containers to remove"
    } else {
        $containers | each { |c| docker rm $c }
        print "Removed all stopped containers"
    }
}

# Remove all dangling images
def drmiall [] {
    let images = (docker images -qf dangling=true | lines)

    if ($images | is-empty) {
        print "No dangling images to remove"
    } else {
        $images | each { |i| docker rmi $i }
        print "Removed all dangling images"
    }
}

# Clean everything (containers, images, volumes, networks)
def dclean [] {
    print "WARNING: This will remove all stopped containers, unused networks, dangling images, and build cache"
    let response = (input "Are you sure? (yes/no): ")

    if $response == "yes" {
        docker system prune -a --volumes -f
        print "Docker cleanup complete!"
    } else {
        print "Aborted"
    }
}

# Exec into container by partial name match
def dex [
    pattern: string
    shell: string = "sh"
] {
    let containers = (docker ps --format '{{.Names}}' | lines)
    let matched = ($containers | where $it =~ $pattern | first)

    if ($matched | is-empty) {
        print $"No running container found matching: ($pattern)"
        print "\nRunning containers:"
        docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'
        return
    }

    print $"Executing into container: ($matched)"
    docker exec -it $matched $shell
}

# Show container logs by partial name match
def dlog [
    pattern: string
    --follow (-f)
] {
    let containers = (docker ps --format '{{.Names}}' | lines)
    let matched = ($containers | where $it =~ $pattern | first)

    if ($matched | is-empty) {
        print $"No running container found matching: ($pattern)"
        return
    }

    if $follow {
        print $"Following logs for: ($matched)"
        docker logs -f $matched
    } else {
        print $"Showing logs for: ($matched)"
        docker logs $matched
    }
}

# Stop container by partial name match
def dstopn [pattern: string] {
    let containers = (docker ps --format '{{.Names}}' | lines)
    let matched = ($containers | where $it =~ $pattern | first)

    if ($matched | is-empty) {
        print $"No running container found matching: ($pattern)"
        return
    }

    print $"Stopping container: ($matched)"
    docker stop $matched
}

# Restart container by partial name match
def drestartn [pattern: string] {
    let containers = (docker ps -a --format '{{.Names}}' | lines)
    let matched = ($containers | where $it =~ $pattern | first)

    if ($matched | is-empty) {
        print $"No container found matching: ($pattern)"
        return
    }

    print $"Restarting container: ($matched)"
    docker restart $matched
}

# Build and tag image with current git commit
def dbuild-git [
    image_name: string
    dockerfile: string = "."
] {
    let git_sha = (do -i { git rev-parse --short HEAD } | complete | get stdout | str trim | default "latest")
    let git_branch = (do -i { git rev-parse --abbrev-ref HEAD } | complete | get stdout | str trim | default "main")

    print $"Building image: ($image_name):($git_sha) \(branch: ($git_branch))"
    docker build -t $"($image_name):($git_sha)" -t $"($image_name):($git_branch)" -t $"($image_name):latest" $dockerfile
}

# Show container resource usage (CPU, Memory)
def dstats [pattern?: string] {
    if $pattern == null {
        docker stats --no-stream
    } else {
        let containers = (docker ps --format '{{.Names}}' | lines)
        let matched = ($containers | where $it =~ $pattern | first)

        if ($matched | is-empty) {
            print $"No running container found matching: ($pattern)"
        } else {
            docker stats --no-stream $matched
        }
    }
}

# Show container port mappings
def dports [pattern?: string] {
    if $pattern == null {
        docker ps --format 'table {{.Names}}\t{{.Ports}}'
    } else {
        let containers = (docker ps --format '{{.Names}}' | lines)
        let matched = ($containers | where $it =~ $pattern | first)

        if ($matched | is-empty) {
            print $"No running container found matching: ($pattern)"
        } else {
            docker port $matched
        }
    }
}

# Docker quick run with common options
def dqrun [image: string, ...args: string] {
    docker run -it --rm $image ...$args
}

# List container volumes
def dvolumes [pattern: string] {
    let containers = (docker ps -a --format '{{.Names}}' | lines)
    let matched = ($containers | where $it =~ $pattern | first)

    if ($matched | is-empty) {
        print $"No container found matching: ($pattern)"
    } else {
        docker inspect -f '{{ .Mounts }}' $matched | str replace -a ',' '\n'
    }
}

# Show all exposed ports for all containers
def dallports [] {
    docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Ports}}'
    | lines
    | where $it =~ '\d+/tcp' or $it =~ '\d+/udp' or $it =~ 'PORTS'
}

# Docker inspect with structured output (nushell JSON)
def dinspectj [
    pattern: string
    query?: string
] {
    let containers = (docker ps -a --format '{{.Names}}' | lines)
    let matched = ($containers | where $it =~ $pattern | first)

    if ($matched | is-empty) {
        print $"No container found matching: ($pattern)"
        return
    }

    let data = (docker inspect $matched | from json)

    if $query == null {
        $data
    } else {
        # For simple queries like .NetworkSettings.IPAddress
        $data | get $query
    }
}

# Get container IP address
def dip [pattern: string] {
    let containers = (docker ps --format '{{.Names}}' | lines)
    let matched = ($containers | where $it =~ $pattern | first)

    if ($matched | is-empty) {
        print $"No running container found matching: ($pattern)"
        return
    }

    docker inspect $matched
    | from json
    | get 0.NetworkSettings.IPAddress
}

# Docker compose logs for specific service
def dclogsvc [
    service: string
    --follow (-f)
] {
    if $follow {
        docker-compose logs -f $service
    } else {
        docker-compose logs $service
    }
}

# List all containers with structured output
def dps-enhanced [] {
    docker ps --format '{{json .}}'
    | lines
    | each { from json }
}

# List all images with structured output
def di-enhanced [] {
    docker images --format '{{json .}}'
    | lines
    | each { from json }
}

# Find containers by image
def dfind-by-image [image: string] {
    docker ps -a --filter ancestor=$image --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
}

# Show container environment variables
def denv [pattern: string] {
    let containers = (docker ps -a --format '{{.Names}}' | lines)
    let matched = ($containers | where $it =~ $pattern | first)

    if ($matched | is-empty) {
        print $"No container found matching: ($pattern)"
        return
    }

    docker inspect $matched
    | from json
    | get 0.Config.Env
}

# Tail logs from multiple containers matching pattern
def dlog-multi [pattern: string] {
    let containers = (docker ps --format '{{.Names}}' | lines | where $it =~ $pattern)

    if ($containers | is-empty) {
        print $"No running containers found matching: ($pattern)"
        return
    }

    print $"Tailing logs from ($containers | length) containers:"
    $containers | each { |c| print $"  - ($c)" }
    print ""

    # Tail logs from all matched containers
    docker logs -f ...($containers)
}

# Remove containers by image name
def drm-by-image [image: string] {
    let containers = (
        docker ps -a --filter ancestor=$image --format '{{.Names}}'
        | lines
    )

    if ($containers | is-empty) {
        print $"No containers found for image: ($image)"
        return
    }

    print $"Found ($containers | length) containers:"
    $containers | each { |c| print $"  - ($c)" }

    let response = (input "Remove these containers? (yes/no): ")
    if $response == "yes" {
        $containers | each { |c| docker rm -f $c }
        print "Containers removed!"
    } else {
        print "Aborted"
    }
}

# Show docker disk usage with breakdown
def ddisk [] {
    print "=== Docker Disk Usage ==="
    docker system df -v
}

# Export container filesystem as tar
def dexport [container: string, output: string] {
    print $"Exporting ($container) to ($output)..."
    docker export $container | save $output
    print $"Exported to ($output)"
}

# Import container filesystem from tar
def dimport [tarfile: string, image_name: string] {
    if not ($tarfile | path exists) {
        print $"Error: File ($tarfile) not found"
        return
    }

    print $"Importing ($tarfile) as ($image_name)..."
    cat $tarfile | docker import - $image_name
    print $"Imported as ($image_name)"
}

# Show running containers count
def dcount [] {
    let total = (docker ps -a | lines | length) - 1
    let running = (docker ps | lines | length) - 1
    let stopped = ($total - $running)

    print $"Total containers: ($total)"
    print $"Running: ($running)"
    print $"Stopped: ($stopped)"
}

# Dive into image layers (if dive is installed)
if (which dive | is-not-empty) {
    def ddive [image: string] {
        dive $image
    }
}
