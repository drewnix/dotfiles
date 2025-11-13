# ╔══════════════════════════════════════════════════════════════╗
# ║ GCP (Google Cloud Platform) Aliases & Functions              ║
# ╚══════════════════════════════════════════════════════════════╝

# Core gcloud commands
export alias gc = gcloud
export alias gci = gcloud init
export alias gcv = gcloud version
export alias ginfo = gcloud info

# Compute Engine - Virtual Machines
export alias gce-ls = gcloud compute instances list
export alias gce-start = gcloud compute instances start
export alias gce-stop = gcloud compute instances stop
export alias gce-delete = gcloud compute instances delete
export alias gce-ssh = gcloud compute ssh
export alias gce-zones = gcloud compute zones list
export alias gce-types = gcloud compute machine-types list

# GKE - Google Kubernetes Engine
export alias gke-ls = gcloud container clusters list
export alias gke-get = gcloud container clusters get-credentials
export alias gke-create = gcloud container clusters create
export alias gke-delete = gcloud container clusters delete
export alias gke-resize = gcloud container clusters resize
export alias gke-upgrade = gcloud container clusters upgrade
export alias gke-nodepools = gcloud container node-pools list --cluster

# Cloud Storage - gsutil
export alias gs = gsutil
export alias gsls = gsutil ls
export alias gscp = gsutil cp
export alias gsrm = gsutil rm
export alias gsmb = gsutil mb
export alias gsrb = gsutil rb
export alias gssync = gsutil -m rsync -r
export alias gsmv = gsutil mv

# Cloud Run - Serverless Containers
export alias gcr-ls = gcloud run services list
export alias gcr-deploy = gcloud run deploy
export alias gcr-delete = gcloud run services delete
export alias gcr-logs = gcloud run services logs read

# Cloud Functions - Serverless Functions
export alias gcf-ls = gcloud functions list
export alias gcf-deploy = gcloud functions deploy
export alias gcf-delete = gcloud functions delete
export alias gcf-logs = gcloud functions logs read
export alias gcf-call = gcloud functions call

# Cloud SQL - Managed Databases
export alias gsql-ls = gcloud sql instances list
export alias gsql-connect = gcloud sql connect
export alias gsql-backup = gcloud sql backups list --instance

# IAM - Identity and Access Management
export alias giam-accounts = gcloud iam service-accounts list
export alias giam-keys = gcloud iam service-accounts keys list --iam-account
export alias giam-roles = gcloud iam roles list
export alias giam-policy = gcloud projects get-iam-policy

# Projects - Project Management
export alias gproj-ls = gcloud projects list
export alias gproj-set = gcloud config set project
export alias gproj-current = gcloud config get-value project

# Configuration - gcloud Config Management
export alias gconf = gcloud config
export alias gconf-ls = gcloud config configurations list
export alias gconf-activate = gcloud config configurations activate
export alias gconf-create = gcloud config configurations create
export alias gconf-set = gcloud config set
export alias gconf-get = gcloud config get-value

# Auth - Authentication
export alias gauth = gcloud auth
export alias gauth-login = gcloud auth login
export alias gauth-list = gcloud auth list
export alias gauth-revoke = gcloud auth revoke
export alias gauth-app = gcloud auth application-default login

# Logging - Cloud Logging
export alias glogs = gcloud logging
export alias glogs-read = gcloud logging read
export alias glogs-tail = gcloud logging tail

# Services - API Services
export alias gsvc-ls = gcloud services list --enabled
export alias gsvc-enable = gcloud services enable
export alias gsvc-disable = gcloud services disable

# Deployment Manager - Infrastructure as Code
export alias gdm-ls = gcloud deployment-manager deployments list
export alias gdm-create = gcloud deployment-manager deployments create
export alias gdm-update = gcloud deployment-manager deployments update
export alias gdm-delete = gcloud deployment-manager deployments delete

# Container Registry / Artifact Registry
export alias gcr-images = gcloud container images list
export alias gar-repos = gcloud artifacts repositories list
export alias gar-packages = gcloud artifacts packages list --repository

# Billing - Cost Management
export alias gbill-accounts = gcloud billing accounts list
export alias gbill-projects = gcloud billing projects list --billing-account

# ╔══════════════════════════════════════════════════════════════╗
# ║ GCP Helper Functions                                         ║
# ╚══════════════════════════════════════════════════════════════╝

# Quick GCP identity/config info
export def gcp-whoami [] {
  print "GCP Configuration:"
  print $"Account: (gcloud config get-value account | str trim)"
  print $"Project: (gcloud config get-value project | str trim)"
  print $"Region: (gcloud config get-value compute/region | str trim)"
  print $"Zone: (gcloud config get-value compute/zone | str trim)"
  print "\nActive Configuration:"
  gcloud config configurations list | lines | where { |line| $line =~ "True" }
}

# Switch GCP project with fuzzy search (requires fzf)
export def gproj-select [] {
  if (which fzf | is-empty) {
    print "Error: fzf is required for this function"
    print "Available projects:"
    gcloud projects list
    return
  }

  let project = (gcloud projects list --format="value(projectId)" | fzf --height 40% --reverse | str trim)

  if ($project | is-empty) {
    return
  }

  gcloud config set project $project
  print $"Switched to project: ($project)"
  gcp-whoami
}

# Switch GCP configuration
export def gconf-switch [config_name?: string] {
  if ($config_name | is-empty) {
    if (which fzf | is-not-empty) {
      let config = (gcloud config configurations list --format="value(name)" | fzf --height 40% --reverse | str trim)

      if ($config | is-not-empty) {
        gcloud config configurations activate $config
        print $"Switched to configuration: ($config)"
        gcp-whoami
      }
    } else {
      print "Usage: gconf-switch <config-name>"
      print "Available configurations:"
      gcloud config configurations list
    }
    return
  }

  gcloud config configurations activate $config_name
  gcp-whoami
}

# Connect to GKE cluster by name pattern
export def gke-use [
  cluster_pattern: string
  location?: string  # Zone or region (auto-detected if not provided)
] {
  let clusters = (gcloud container clusters list --format="csv[no-heading](name,location)" | lines)

  let matching_cluster = ($clusters | parse "{name},{location}" | where name =~ $"(?i)($cluster_pattern)" | first)

  if ($matching_cluster | is-empty) {
    print $"No cluster found matching: ($cluster_pattern)"
    print "\nAvailable clusters:"
    gcloud container clusters list
    return
  }

  let cluster_name = $matching_cluster.name
  let cluster_location = if ($location | is-empty) {
    $matching_cluster.location
  } else {
    $location
  }

  print $"Getting credentials for cluster: ($cluster_name) in ($cluster_location)"
  gcloud container clusters get-credentials $cluster_name --location=$cluster_location
}

# SSH into GCE instance by name pattern
export def gce-ssh-name [
  instance_pattern: string
  zone?: string  # Zone (auto-detected if not provided)
] {
  let instances = (gcloud compute instances list --format="csv[no-heading](name,zone)" | lines)

  let matching_instance = ($instances | parse "{name},{zone}" | where name =~ $"(?i)($instance_pattern)" | first)

  if ($matching_instance | is-empty) {
    print $"No instance found matching: ($instance_pattern)"
    print "\nAvailable instances:"
    gcloud compute instances list
    return
  }

  let instance_name = $matching_instance.name
  let instance_zone = if ($zone | is-empty) {
    $matching_instance.zone
  } else {
    $zone
  }

  print $"Connecting to instance: ($instance_name) in zone: ($instance_zone)"
  gcloud compute ssh $instance_name --zone=$instance_zone
}

# Tail Cloud Run logs by service name
export def gcr-logs-tail [
  service_name: string
  region?: string  # Region (uses config default if not provided)
] {
  let service_region = if ($region | is-empty) {
    gcloud config get-value run/region | str trim
  } else {
    $region
  }

  print $"Tailing logs for service: ($service_name) in region: ($service_region)"
  gcloud run services logs tail $service_name --region=$service_region
}

# List all GCP regions
export def gcp-regions [] {
  gcloud compute regions list --format="table(name,status)" --sort-by=name
}

# List all GCP zones
export def gcp-zones [region?: string] {
  if ($region | is-not-empty) {
    gcloud compute zones list --filter=$"region:($region)" --format="table(name,status)" --sort-by=name
  } else {
    gcloud compute zones list --format="table(name,region,status)" --sort-by=name
  }
}

# Set default region and zone
export def gcp-set-location [
  region: string
  zone: string
] {
  gcloud config set compute/region $region
  gcloud config set compute/zone $zone
  print $"Set region to ($region) and zone to ($zone)"
}

# List Cloud Storage buckets with details
export def gs-buckets [] {
  print "Cloud Storage Buckets:"
  gsutil ls -L | lines | reduce -f {bucket: "", class: "", type: "", location: ""} { |line, acc|
    if ($line | str starts-with "gs://") {
      if ($acc.bucket | is-not-empty) {
        print $"($acc.bucket)"
        print $"  Class: ($acc.class)"
        print $"  Type: ($acc.type)"
        print $"  Location: ($acc.location)"
        print ""
      }
      {bucket: $line, class: "", type: "", location: ""}
    } else if ($line | str contains "Storage class:") {
      $acc | update class ($line | split row ":" | get 1 | str trim)
    } else if ($line | str contains "Location type:") {
      $acc | update type ($line | split row ":" | get 1 | str trim)
    } else if ($line | str contains "Location constraint:") {
      $acc | update location ($line | split row ":" | get 1 | str trim)
    } else {
      $acc
    }
  }
}

# Get Cloud Function logs by name
export def gcf-logs-tail [function_name: string] {
  print $"Tailing logs for function: ($function_name)"
  gcloud functions logs read $function_name --limit=50

  print "\nFollowing logs (Ctrl+C to exit)..."
  loop {
    sleep 2sec
    gcloud functions logs read $function_name --limit=10
  }
}

# Enable common GCP APIs
export def gcp-enable-common-apis [] {
  print "Enabling common GCP APIs..."

  let apis = [
    "compute.googleapis.com"
    "container.googleapis.com"
    "storage-api.googleapis.com"
    "cloudfunctions.googleapis.com"
    "run.googleapis.com"
    "sqladmin.googleapis.com"
    "logging.googleapis.com"
    "monitoring.googleapis.com"
  ]

  gcloud services enable ...$apis
  print "Common APIs enabled!"
}

# Quick project switch and K8s context update
export def gcp-switch [project_id: string] {
  print $"Switching to project: ($project_id)"
  gcloud config set project $project_id

  # Try to update kubeconfig if GKE cluster exists
  let clusters = (gcloud container clusters list --format="value(name)" | lines)
  let cluster = $clusters | first

  if ($cluster | is-not-empty) {
    print $"Found GKE cluster: ($cluster), updating kubeconfig..."
    gke-use $cluster
  }

  gcp-whoami
}

# List GCP projects as structured data
export def gcp-list-projects [] {
  gcloud projects list --format=json | from json
}

# Get current GCP project
export def gcp-current-project [] {
  gcloud config get-value project | str trim
}

# List GCE instances as structured data
export def gce-list [] {
  gcloud compute instances list --format=json | from json
}

# Get GCE instance details
export def gce-get [instance_name: string, zone?: string] {
  if ($zone | is-empty) {
    let zone_value = (gcloud config get-value compute/zone | str trim)
    gcloud compute instances describe $instance_name --zone=$zone_value --format=json | from json
  } else {
    gcloud compute instances describe $instance_name --zone=$zone --format=json | from json
  }
}

# List GKE clusters as structured data
export def gke-list [] {
  gcloud container clusters list --format=json | from json
}

# Get GKE cluster details
export def gke-get-details [cluster_name: string, location?: string] {
  if ($location | is-empty) {
    let clusters = (gke-list)
    let cluster = ($clusters | where name == $cluster_name | first)
    if ($cluster | is-empty) {
      print $"Cluster not found: ($cluster_name)"
      return
    }
    gcloud container clusters describe $cluster_name --location=($cluster.location) --format=json | from json
  } else {
    gcloud container clusters describe $cluster_name --location=$location --format=json | from json
  }
}

# List Cloud Storage buckets as structured data
export def gs-list-buckets [] {
  gsutil ls -L -b gs://** | lines | reduce -f [] { |line, acc|
    if ($line | str starts-with "gs://") {
      $acc | append {bucket: ($line | str trim)}
    } else {
      $acc
    }
  }
}

# Get Cloud Storage bucket size
export def gs-bucket-size [bucket: string] {
  gsutil du -sh $"gs://($bucket)"
}

# List Cloud Run services as structured data
export def gcr-list [] {
  gcloud run services list --format=json | from json
}

# Get Cloud Run service details
export def gcr-get [service_name: string, region?: string] {
  if ($region | is-empty) {
    let region_value = (gcloud config get-value run/region | str trim)
    gcloud run services describe $service_name --region=$region_value --format=json | from json
  } else {
    gcloud run services describe $service_name --region=$region --format=json | from json
  }
}

# List Cloud Functions as structured data
export def gcf-list [] {
  gcloud functions list --format=json | from json
}

# Get Cloud Function details
export def gcf-get [function_name: string] {
  gcloud functions describe $function_name --format=json | from json
}

# List Cloud SQL instances as structured data
export def gsql-list [] {
  gcloud sql instances list --format=json | from json
}

# Get Cloud SQL instance details
export def gsql-get [instance_name: string] {
  gcloud sql instances describe $instance_name --format=json | from json
}

# List IAM service accounts as structured data
export def giam-list-accounts [] {
  gcloud iam service-accounts list --format=json | from json
}

# Get IAM policy for project
export def giam-get-policy [project_id?: string] {
  if ($project_id | is-empty) {
    let project = (gcp-current-project)
    gcloud projects get-iam-policy $project --format=json | from json
  } else {
    gcloud projects get-iam-policy $project_id --format=json | from json
  }
}

# List enabled services/APIs
export def gsvc-list [] {
  gcloud services list --enabled --format=json | from json
}

# List available services/APIs
export def gsvc-available [] {
  gcloud services list --available --format=json | from json
}

# List Deployment Manager deployments as structured data
export def gdm-list [] {
  gcloud deployment-manager deployments list --format=json | from json
}

# Get Deployment Manager deployment details
export def gdm-get [deployment_name: string] {
  gcloud deployment-manager deployments describe $deployment_name --format=json | from json
}

# List Container Registry images
export def gcr-list-images [repository?: string] {
  if ($repository | is-empty) {
    gcloud container images list --format=json | from json
  } else {
    gcloud container images list --repository=$repository --format=json | from json
  }
}

# List Artifact Registry repositories
export def gar-list-repos [location?: string] {
  if ($location | is-empty) {
    gcloud artifacts repositories list --format=json | from json
  } else {
    gcloud artifacts repositories list --location=$location --format=json | from json
  }
}

# List billing accounts as structured data
export def gbill-list-accounts [] {
  gcloud billing accounts list --format=json | from json
}

# Get current account info
export def gcp-account [] {
  gcloud config get-value account | str trim
}

# List all authenticated accounts
export def gcp-accounts [] {
  gcloud auth list --format=json | from json
}

# Get GCP regions with details
export def gcp-regions-detailed [] {
  gcloud compute regions list --format=json | from json
}

# Get GCP zones with details
export def gcp-zones-detailed [region?: string] {
  if ($region | is-not-empty) {
    gcloud compute zones list --filter=$"region:($region)" --format=json | from json
  } else {
    gcloud compute zones list --format=json | from json
  }
}

# List machine types for a zone
export def gce-machine-types [zone?: string] {
  if ($zone | is-empty) {
    let zone_value = (gcloud config get-value compute/zone | str trim)
    gcloud compute machine-types list --zones=$zone_value --format=json | from json
  } else {
    gcloud compute machine-types list --zones=$zone --format=json | from json
  }
}

# List disk types for a zone
export def gce-disk-types [zone?: string] {
  if ($zone | is-empty) {
    let zone_value = (gcloud config get-value compute/zone | str trim)
    gcloud compute disk-types list --zones=$zone_value --format=json | from json
  } else {
    gcloud compute disk-types list --zones=$zone --format=json | from json
  }
}

# List GCE images
export def gce-images [project?: string] {
  if ($project | is-empty) {
    gcloud compute images list --format=json | from json
  } else {
    gcloud compute images list --project=$project --format=json | from json
  }
}

# List GCE snapshots
export def gce-snapshots [] {
  gcloud compute snapshots list --format=json | from json
}

# List GCE disks
export def gce-disks [zone?: string] {
  if ($zone | is-empty) {
    gcloud compute disks list --format=json | from json
  } else {
    gcloud compute disks list --zones=$zone --format=json | from json
  }
}

# List VPC networks
export def gcp-networks [] {
  gcloud compute networks list --format=json | from json
}

# List VPC subnets
export def gcp-subnets [network?: string, region?: string] {
  if ($network | is-not-empty) and ($region | is-not-empty) {
    gcloud compute networks subnets list --network=$network --regions=$region --format=json | from json
  } else if ($network | is-not-empty) {
    gcloud compute networks subnets list --network=$network --format=json | from json
  } else if ($region | is-not-empty) {
    gcloud compute networks subnets list --regions=$region --format=json | from json
  } else {
    gcloud compute networks subnets list --format=json | from json
  }
}

# List firewall rules
export def gcp-firewall-rules [network?: string] {
  if ($network | is-empty) {
    gcloud compute firewall-rules list --format=json | from json
  } else {
    gcloud compute firewall-rules list --filter=$"network:($network)" --format=json | from json
  }
}

# List GKE node pools for a cluster
export def gke-list-nodepools [cluster: string, location?: string] {
  if ($location | is-empty) {
    let clusters = (gke-list)
    let cluster_info = ($clusters | where name == $cluster | first)
    if ($cluster_info | is-empty) {
      print $"Cluster not found: ($cluster)"
      return
    }
    gcloud container node-pools list --cluster=$cluster --location=($cluster_info.location) --format=json | from json
  } else {
    gcloud container node-pools list --cluster=$cluster --location=$location --format=json | from json
  }
}

# Get GKE node pool details
export def gke-get-nodepool [cluster: string, nodepool: string, location?: string] {
  if ($location | is-empty) {
    let clusters = (gke-list)
    let cluster_info = ($clusters | where name == $cluster | first)
    if ($cluster_info | is-empty) {
      print $"Cluster not found: ($cluster)"
      return
    }
    gcloud container node-pools describe $nodepool --cluster=$cluster --location=($cluster_info.location) --format=json | from json
  } else {
    gcloud container node-pools describe $nodepool --cluster=$cluster --location=$location --format=json | from json
  }
}

# List Cloud Logging sinks
export def glogs-sinks [] {
  gcloud logging sinks list --format=json | from json
}

# List Cloud Logging metrics
export def glogs-metrics [] {
  gcloud logging metrics list --format=json | from json
}

# Get quota for a service
export def gcp-quota [service: string] {
  gcloud compute project-info describe --format=json | from json | get quotas | where metric == $service
}

# List all quotas
export def gcp-quotas [] {
  gcloud compute project-info describe --format=json | from json | get quotas
}

# Get current GCP configuration as structured data
export def gcp-config [] {
  {
    account: (gcloud config get-value account | str trim)
    project: (gcloud config get-value project | str trim)
    region: (gcloud config get-value compute/region | str trim)
    zone: (gcloud config get-value compute/zone | str trim)
  }
}

# Switch between multiple GCP configurations easily
export def gcp-configs [] {
  gcloud config configurations list --format=json | from json
}

# Create a new GCP configuration
export def gcp-config-create [
  config_name: string
  --project(-p): string = ""
  --account(-a): string = ""
  --region(-r): string = ""
  --zone(-z): string = ""
] {
  gcloud config configurations create $config_name

  if ($project | is-not-empty) {
    gcloud config set project $project --configuration=$config_name
  }

  if ($account | is-not-empty) {
    gcloud config set account $account --configuration=$config_name
  }

  if ($region | is-not-empty) {
    gcloud config set compute/region $region --configuration=$config_name
  }

  if ($zone | is-not-empty) {
    gcloud config set compute/zone $zone --configuration=$config_name
  }

  print $"Configuration ($config_name) created successfully"
}

# Delete a GCP configuration
export def gcp-config-delete [config_name: string] {
  gcloud config configurations delete $config_name
  print $"Configuration ($config_name) deleted"
}

# Get GCE instance external IP
export def gce-ip [instance_name: string, zone?: string] {
  if ($zone | is-empty) {
    let zone_value = (gcloud config get-value compute/zone | str trim)
    gcloud compute instances describe $instance_name --zone=$zone_value --format="value(networkInterfaces[0].accessConfigs[0].natIP)" | str trim
  } else {
    gcloud compute instances describe $instance_name --zone=$zone --format="value(networkInterfaces[0].accessConfigs[0].natIP)" | str trim
  }
}

# Get GCE instance internal IP
export def gce-internal-ip [instance_name: string, zone?: string] {
  if ($zone | is-empty) {
    let zone_value = (gcloud config get-value compute/zone | str trim)
    gcloud compute instances describe $instance_name --zone=$zone_value --format="value(networkInterfaces[0].networkIP)" | str trim
  } else {
    gcloud compute instances describe $instance_name --zone=$zone --format="value(networkInterfaces[0].networkIP)" | str trim
  }
}
