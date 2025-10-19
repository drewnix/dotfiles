# ╔══════════════════════════════════════════════════════════════╗
# ║ GCP (Google Cloud Platform) Aliases & Functions              ║
# ╚══════════════════════════════════════════════════════════════╝

# Core gcloud commands
alias gc='gcloud'
alias gci='gcloud init'
alias gcv='gcloud version'
alias ginfo='gcloud info'

# Compute Engine
alias gce-ls='gcloud compute instances list'
alias gce-start='gcloud compute instances start'
alias gce-stop='gcloud compute instances stop'
alias gce-delete='gcloud compute instances delete'
alias gce-ssh='gcloud compute ssh'
alias gce-zones='gcloud compute zones list'
alias gce-types='gcloud compute machine-types list'

# GKE (Google Kubernetes Engine)
alias gke-ls='gcloud container clusters list'
alias gke-get='gcloud container clusters get-credentials'
alias gke-create='gcloud container clusters create'
alias gke-delete='gcloud container clusters delete'
alias gke-resize='gcloud container clusters resize'
alias gke-upgrade='gcloud container clusters upgrade'
alias gke-nodepools='gcloud container node-pools list --cluster'

# Cloud Storage (gsutil)
alias gs='gsutil'
alias gsls='gsutil ls'
alias gscp='gsutil cp'
alias gsrm='gsutil rm'
alias gsmb='gsutil mb'
alias gsrb='gsutil rb'
alias gssync='gsutil -m rsync -r'
alias gsmv='gsutil mv'

# Cloud Run
alias gcr-ls='gcloud run services list'
alias gcr-deploy='gcloud run deploy'
alias gcr-delete='gcloud run services delete'
alias gcr-logs='gcloud run services logs read'

# Cloud Functions
alias gcf-ls='gcloud functions list'
alias gcf-deploy='gcloud functions deploy'
alias gcf-delete='gcloud functions delete'
alias gcf-logs='gcloud functions logs read'
alias gcf-call='gcloud functions call'

# Cloud SQL
alias gsql-ls='gcloud sql instances list'
alias gsql-connect='gcloud sql connect'
alias gsql-backup='gcloud sql backups list --instance'

# IAM
alias giam-accounts='gcloud iam service-accounts list'
alias giam-keys='gcloud iam service-accounts keys list --iam-account'
alias giam-roles='gcloud iam roles list'
alias giam-policy='gcloud projects get-iam-policy'

# Projects
alias gproj-ls='gcloud projects list'
alias gproj-set='gcloud config set project'
alias gproj-current='gcloud config get-value project'

# Configuration
alias gconf='gcloud config'
alias gconf-ls='gcloud config configurations list'
alias gconf-activate='gcloud config configurations activate'
alias gconf-create='gcloud config configurations create'
alias gconf-set='gcloud config set'
alias gconf-get='gcloud config get-value'

# Auth
alias gauth='gcloud auth'
alias gauth-login='gcloud auth login'
alias gauth-list='gcloud auth list'
alias gauth-revoke='gcloud auth revoke'
alias gauth-app='gcloud auth application-default login'

# Logging
alias glogs='gcloud logging'
alias glogs-read='gcloud logging read'
alias glogs-tail='gcloud logging tail'

# Services
alias gsvc-ls='gcloud services list --enabled'
alias gsvc-enable='gcloud services enable'
alias gsvc-disable='gcloud services disable'

# Deployment Manager
alias gdm-ls='gcloud deployment-manager deployments list'
alias gdm-create='gcloud deployment-manager deployments create'
alias gdm-update='gcloud deployment-manager deployments update'
alias gdm-delete='gcloud deployment-manager deployments delete'

# Container Registry/Artifact Registry
alias gcr-images='gcloud container images list'
alias gar-repos='gcloud artifacts repositories list'
alias gar-packages='gcloud artifacts packages list --repository'

# Billing
alias gbill-accounts='gcloud billing accounts list'
alias gbill-projects='gcloud billing projects list --billing-account'

# ╔══════════════════════════════════════════════════════════════╗
# ║ GCP Helper Functions                                         ║
# ╚══════════════════════════════════════════════════════════════╝

# Quick GCP identity/config info
gcp-whoami() {
  echo "GCP Configuration:"
  echo "Account: $(gcloud config get-value account)"
  echo "Project: $(gcloud config get-value project)"
  echo "Region: $(gcloud config get-value compute/region)"
  echo "Zone: $(gcloud config get-value compute/zone)"
  echo "\nActive Configuration:"
  gcloud config configurations list | grep True
}

# Switch GCP project with fuzzy search (requires fzf)
gproj-select() {
  if command -v fzf &> /dev/null; then
    local project=$(gcloud projects list --format="value(projectId)" | fzf --height 40% --reverse)
    if [ -n "$project" ]; then
      gcloud config set project $project
      echo "Switched to project: $project"
      gcp-whoami
    fi
  else
    echo "Error: fzf is required for this function"
    echo "Available projects:"
    gcloud projects list
  fi
}

# Switch GCP configuration
gconf-switch() {
  if [ -z "$1" ]; then
    if command -v fzf &> /dev/null; then
      local config=$(gcloud config configurations list --format="value(name)" | fzf --height 40% --reverse)
      if [ -n "$config" ]; then
        gcloud config configurations activate $config
        echo "Switched to configuration: $config"
        gcp-whoami
      fi
    else
      echo "Usage: gconf-switch <config-name>"
      echo "Available configurations:"
      gcloud config configurations list
    fi
    return 0
  fi
  gcloud config configurations activate $1
  gcp-whoami
}

# Connect to GKE cluster by name pattern
gke-use() {
  if [ -z "$1" ]; then
    echo "Usage: gke-use <cluster-name-pattern> [zone-or-region]"
    return 1
  fi

  local cluster=$(gcloud container clusters list --format="value(name)" | grep -i "$1" | head -1)
  if [ -n "$cluster" ]; then
    local location="${2:-$(gcloud container clusters list --filter="name=$cluster" --format="value(location)" | head -1)}"
    echo "Getting credentials for cluster: $cluster in $location"
    gcloud container clusters get-credentials "$cluster" --location="$location"
  else
    echo "No cluster found matching: $1"
    echo "\nAvailable clusters:"
    gcloud container clusters list
  fi
}

# SSH into GCE instance by name pattern
gce-ssh-name() {
  if [ -z "$1" ]; then
    echo "Usage: gce-ssh-name <instance-name-pattern> [zone]"
    return 1
  fi

  local instance=$(gcloud compute instances list --format="value(name)" | grep -i "$1" | head -1)
  if [ -n "$instance" ]; then
    local zone="${2:-$(gcloud compute instances list --filter="name=$instance" --format="value(zone)" | head -1)}"
    echo "Connecting to instance: $instance in zone: $zone"
    gcloud compute ssh "$instance" --zone="$zone"
  else
    echo "No instance found matching: $1"
    echo "\nAvailable instances:"
    gcloud compute instances list
  fi
}

# Tail Cloud Run logs by service name
gcr-logs-tail() {
  if [ -z "$1" ]; then
    echo "Usage: gcr-logs-tail <service-name> [region]"
    return 1
  fi

  local service=$1
  local region="${2:-$(gcloud config get-value run/region)}"

  echo "Tailing logs for service: $service in region: $region"
  gcloud run services logs tail "$service" --region="$region"
}

# List all GCP regions
gcp-regions() {
  gcloud compute regions list --format="table(name,status)" --sort-by=name
}

# List all GCP zones
gcp-zones() {
  if [ -n "$1" ]; then
    gcloud compute zones list --filter="region:$1" --format="table(name,status)" --sort-by=name
  else
    gcloud compute zones list --format="table(name,region,status)" --sort-by=name
  fi
}

# Set default region and zone
gcp-set-location() {
  if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: gcp-set-location <region> <zone>"
    echo "Example: gcp-set-location us-central1 us-central1-a"
    return 1
  fi
  gcloud config set compute/region $1
  gcloud config set compute/zone $2
  echo "Set region to $1 and zone to $2"
}

# List Cloud Storage buckets with size
gs-buckets() {
  echo "Cloud Storage Buckets:"
  gsutil ls -L | grep -E "(gs://|Storage class:|Location type:|Location constraint:)" | \
    awk 'BEGIN {bucket=""} /gs:\/\// {if(bucket!="") print ""; bucket=$1; printf "%s\n", bucket} /Storage class:/ {printf "  Class: %s\n", $3} /Location type:/ {printf "  Type: %s\n", $3} /Location constraint:/ {printf "  Location: %s\n", $3}'
}

# Get Cloud Function logs by name
gcf-logs-tail() {
  if [ -z "$1" ]; then
    echo "Usage: gcf-logs-tail <function-name>"
    return 1
  fi

  echo "Tailing logs for function: $1"
  gcloud functions logs read "$1" --limit=50
  echo "\nFollowing logs (Ctrl+C to exit)..."
  while true; do
    sleep 2
    gcloud functions logs read "$1" --limit=10
  done
}

# Enable common GCP APIs
gcp-enable-common-apis() {
  echo "Enabling common GCP APIs..."
  gcloud services enable \
    compute.googleapis.com \
    container.googleapis.com \
    storage-api.googleapis.com \
    cloudfunctions.googleapis.com \
    run.googleapis.com \
    sqladmin.googleapis.com \
    logging.googleapis.com \
    monitoring.googleapis.com
  echo "Common APIs enabled!"
}

# Quick project switch and K8s context update
gcp-switch() {
  if [ -z "$1" ]; then
    echo "Usage: gcp-switch <project-id>"
    return 1
  fi

  echo "Switching to project: $1"
  gcloud config set project $1

  # Try to update kubeconfig if GKE cluster exists
  local cluster=$(gcloud container clusters list --format="value(name)" | head -1)
  if [ -n "$cluster" ]; then
    echo "Found GKE cluster: $cluster, updating kubeconfig..."
    gke-use $cluster
  fi

  gcp-whoami
}
