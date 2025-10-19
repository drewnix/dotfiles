# ╔══════════════════════════════════════════════════════════════╗
# ║ Docker & Container Aliases                                   ║
# ╚══════════════════════════════════════════════════════════════╝

# Core Docker commands
alias d='docker'
alias di='docker images'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias drm='docker rm'
alias drmi='docker rmi'
alias drun='docker run'
alias dexec='docker exec -it'
alias dlogs='docker logs'
alias dlogsf='docker logs -f'
alias dstop='docker stop'
alias dstart='docker start'
alias drestart='docker restart'
alias dinspect='docker inspect'
alias dpull='docker pull'
alias dpush='docker push'
alias dbuild='docker build'
alias dtag='docker tag'

# Docker system
alias dinfo='docker info'
alias dversion='docker version'
alias dsystem='docker system'
alias ddf='docker system df'
alias dprune='docker system prune'
alias dprunea='docker system prune -a'
alias dprunev='docker system prune --volumes'

# Docker compose
alias dc='docker-compose'
alias dcu='docker-compose up'
alias dcud='docker-compose up -d'
alias dcd='docker-compose down'
alias dcb='docker-compose build'
alias dcr='docker-compose run'
alias dce='docker-compose exec'
alias dclogs='docker-compose logs'
alias dclogsf='docker-compose logs -f'
alias dcps='docker-compose ps'
alias dcrestart='docker-compose restart'
alias dcstop='docker-compose stop'
alias dcstart='docker-compose start'
alias dcpull='docker-compose pull'

# Docker compose v2 (docker compose without hyphen)
alias dkc='docker compose'
alias dkcu='docker compose up'
alias dkcud='docker compose up -d'
alias dkcd='docker compose down'
alias dkcb='docker compose build'
alias dkcr='docker compose run'
alias dkce='docker compose exec'
alias dkclogs='docker compose logs'
alias dkclogsf='docker compose logs -f'
alias dkcps='docker compose ps'
alias dkcrestart='docker compose restart'

# Docker networks
alias dnet='docker network'
alias dnetls='docker network ls'
alias dnetrm='docker network rm'
alias dnetinspect='docker network inspect'

# Docker volumes
alias dvol='docker volume'
alias dvolls='docker volume ls'
alias dvolrm='docker volume rm'
alias dvolinspect='docker volume inspect'
alias dvolprune='docker volume prune'

# Container registry operations
alias dcr-login='docker login'
alias dcr-logout='docker logout'

# Podman (Docker alternative) - if installed
if command -v podman &> /dev/null; then
  alias p='podman'
  alias pi='podman images'
  alias pps='podman ps'
  alias ppsa='podman ps -a'
  alias prm='podman rm'
  alias prmi='podman rmi'
  alias prun='podman run'
  alias pexec='podman exec -it'
  alias plogs='podman logs'
  alias pstop='podman stop'
  alias pstart='podman start'
fi

# ╔══════════════════════════════════════════════════════════════╗
# ║ Docker Helper Functions                                      ║
# ╚══════════════════════════════════════════════════════════════╝

# Stop all running containers
dstopall() {
  local containers=$(docker ps -q)
  if [ -n "$containers" ]; then
    docker stop $containers
    echo "Stopped all running containers"
  else
    echo "No running containers"
  fi
}

# Remove all stopped containers
drmall() {
  local containers=$(docker ps -aq -f status=exited)
  if [ -n "$containers" ]; then
    docker rm $containers
    echo "Removed all stopped containers"
  else
    echo "No stopped containers to remove"
  fi
}

# Remove all dangling images
drmiall() {
  local images=$(docker images -qf dangling=true)
  if [ -n "$images" ]; then
    docker rmi $images
    echo "Removed all dangling images"
  else
    echo "No dangling images to remove"
  fi
}

# Clean everything (containers, images, volumes, networks)
dclean() {
  echo "WARNING: This will remove all stopped containers, unused networks, dangling images, and build cache"
  read "response?Are you sure? (yes/no): "
  if [ "$response" = "yes" ]; then
    docker system prune -a --volumes -f
    echo "Docker cleanup complete!"
  else
    echo "Aborted"
  fi
}

# Exec into container by partial name match
dex() {
  if [ -z "$1" ]; then
    echo "Usage: dex <container-name-pattern> [shell]"
    return 1
  fi

  local shell="${2:-sh}"
  local container=$(docker ps --format '{{.Names}}' | grep "$1" | head -1)

  if [ -z "$container" ]; then
    echo "No running container found matching: $1"
    echo "\nRunning containers:"
    docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'
    return 1
  fi

  echo "Executing into container: $container"
  docker exec -it $container $shell
}

# Show container logs by partial name match
dlog() {
  if [ -z "$1" ]; then
    echo "Usage: dlog <container-name-pattern> [--follow]"
    return 1
  fi

  local container=$(docker ps --format '{{.Names}}' | grep "$1" | head -1)

  if [ -z "$container" ]; then
    echo "No running container found matching: $1"
    return 1
  fi

  if [ "$2" = "-f" ] || [ "$2" = "--follow" ]; then
    echo "Following logs for: $container"
    docker logs -f $container
  else
    echo "Showing logs for: $container"
    docker logs $container
  fi
}

# Stop container by partial name match
dstopn() {
  if [ -z "$1" ]; then
    echo "Usage: dstopn <container-name-pattern>"
    return 1
  fi

  local container=$(docker ps --format '{{.Names}}' | grep "$1" | head -1)

  if [ -z "$container" ]; then
    echo "No running container found matching: $1"
    return 1
  fi

  echo "Stopping container: $container"
  docker stop $container
}

# Restart container by partial name match
drestartn() {
  if [ -z "$1" ]; then
    echo "Usage: drestartn <container-name-pattern>"
    return 1
  fi

  local container=$(docker ps -a --format '{{.Names}}' | grep "$1" | head -1)

  if [ -z "$container" ]; then
    echo "No container found matching: $1"
    return 1
  fi

  echo "Restarting container: $container"
  docker restart $container
}

# Build and tag image with current git commit
dbuild-git() {
  if [ -z "$1" ]; then
    echo "Usage: dbuild-git <image-name> [dockerfile-path]"
    return 1
  fi

  local image_name=$1
  local dockerfile="${2:-.}"
  local git_sha=$(git rev-parse --short HEAD 2>/dev/null || echo "latest")
  local git_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")

  echo "Building image: $image_name:$git_sha (branch: $git_branch)"
  docker build -t "$image_name:$git_sha" -t "$image_name:$git_branch" -t "$image_name:latest" $dockerfile
}

# Show container resource usage (CPU, Memory)
dstats() {
  if [ -z "$1" ]; then
    docker stats --no-stream
  else
    local container=$(docker ps --format '{{.Names}}' | grep "$1" | head -1)
    if [ -n "$container" ]; then
      docker stats --no-stream $container
    else
      echo "No running container found matching: $1"
    fi
  fi
}

# Show container port mappings
dports() {
  if [ -z "$1" ]; then
    docker ps --format 'table {{.Names}}\t{{.Ports}}'
  else
    local container=$(docker ps --format '{{.Names}}' | grep "$1" | head -1)
    if [ -n "$container" ]; then
      docker port $container
    else
      echo "No running container found matching: $1"
    fi
  fi
}

# Docker quick run with common options
dqrun() {
  if [ -z "$1" ]; then
    echo "Usage: dqrun <image> [command]"
    return 1
  fi

  local image=$1
  shift
  docker run -it --rm $image "$@"
}

# List container volumes
dvolumes() {
  if [ -z "$1" ]; then
    echo "Usage: dvolumes <container-name-pattern>"
    return 1
  fi

  local container=$(docker ps -a --format '{{.Names}}' | grep "$1" | head -1)
  if [ -n "$container" ]; then
    docker inspect -f '{{ .Mounts }}' $container | tr ',' '\n'
  else
    echo "No container found matching: $1"
  fi
}

# Show all exposed ports for all containers
dallports() {
  docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Ports}}' | awk 'NR==1 || $3 != ""'
}

# Docker inspect with jq (if available)
dinspectj() {
  if ! command -v jq &> /dev/null; then
    echo "Error: jq is required for this function"
    return 1
  fi

  if [ -z "$1" ]; then
    echo "Usage: dinspectj <container-name-pattern> [jq-query]"
    echo "Example: dinspectj nginx '.[0].NetworkSettings.IPAddress'"
    return 1
  fi

  local container=$(docker ps -a --format '{{.Names}}' | grep "$1" | head -1)
  if [ -n "$container" ]; then
    if [ -n "$2" ]; then
      docker inspect $container | jq "$2"
    else
      docker inspect $container | jq '.'
    fi
  else
    echo "No container found matching: $1"
  fi
}

# Docker compose logs for specific service
dclogsvc() {
  if [ -z "$1" ]; then
    echo "Usage: dclogsvc <service-name> [-f|--follow]"
    return 1
  fi

  if [ "$2" = "-f" ] || [ "$2" = "--follow" ]; then
    docker-compose logs -f $1
  else
    docker-compose logs $1
  fi
}
