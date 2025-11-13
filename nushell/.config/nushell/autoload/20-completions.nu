# Custom Completions
# Advanced completions for kubectl contexts, terraform workspaces, AWS profiles, GCP projects, etc.

# ============================================================================
# Kubectl Context Completions
# ============================================================================

# Complete kubectl contexts
def "nu-complete kube contexts" [] {
    ^kubectl config get-contexts -o name | lines | where $it != ""
}

# Complete kubectl namespaces from current cluster
def "nu-complete kube namespaces" [] {
    ^kubectl get namespaces -o jsonpath='{.items[*].metadata.name}' | split row ' '
}

# Complete kubectl resource types
def "nu-complete kube resources" [] {
    [
        "pods" "po"
        "deployments" "deploy"
        "services" "svc"
        "configmaps" "cm"
        "secrets"
        "namespaces" "ns"
        "nodes" "no"
        "persistentvolumes" "pv"
        "persistentvolumeclaims" "pvc"
        "statefulsets" "sts"
        "daemonsets" "ds"
        "replicasets" "rs"
        "jobs"
        "cronjobs" "cj"
        "ingresses" "ing"
        "networkpolicies" "netpol"
        "serviceaccounts" "sa"
        "roles"
        "rolebindings"
        "clusterroles"
        "clusterrolebindings"
    ]
}

# ============================================================================
# Terraform Workspace Completions
# ============================================================================

# Complete terraform workspaces
def "nu-complete tf workspaces" [] {
    if not (".terraform" | path exists) {
        return []
    }

    ^terraform workspace list
    | lines
    | each { str trim | str replace '*' '' | str trim }
    | where $it != ""
}

# ============================================================================
# AWS Profile Completions
# ============================================================================

# Complete AWS profiles from ~/.aws/config and ~/.aws/credentials
def "nu-complete aws profiles" [] {
    let config_file = ($env.HOME | path join ".aws" "config")
    let creds_file = ($env.HOME | path join ".aws" "credentials")

    mut profiles = []

    # Parse config file
    if ($config_file | path exists) {
        let config_profiles = (
            open $config_file
            | lines
            | where $it =~ '^\[profile '
            | each { str replace '\[profile ' '' | str replace '\]' '' | str trim }
        )
        $profiles = ($profiles | append $config_profiles)
    }

    # Parse credentials file
    if ($creds_file | path exists) {
        let cred_profiles = (
            open $creds_file
            | lines
            | where $it =~ '^\['
            | each { str replace '\[' '' | str replace '\]' '' | str trim }
        )
        $profiles = ($profiles | append $cred_profiles)
    }

    $profiles | uniq | sort
}

# Complete AWS regions
def "nu-complete aws regions" [] {
    [
        "us-east-1" "us-east-2" "us-west-1" "us-west-2"
        "ca-central-1"
        "eu-west-1" "eu-west-2" "eu-west-3" "eu-central-1" "eu-north-1"
        "ap-south-1" "ap-northeast-1" "ap-northeast-2" "ap-northeast-3"
        "ap-southeast-1" "ap-southeast-2"
        "sa-east-1"
    ]
}

# ============================================================================
# GCP Project Completions
# ============================================================================

# Complete GCP projects
def "nu-complete gcp projects" [] {
    if (which gcloud | is-empty) {
        return []
    }

    ^gcloud projects list --format='value(projectId)' | lines | where $it != ""
}

# Complete GCP zones
def "nu-complete gcp zones" [] {
    [
        "us-central1-a" "us-central1-b" "us-central1-c" "us-central1-f"
        "us-east1-b" "us-east1-c" "us-east1-d"
        "us-west1-a" "us-west1-b" "us-west1-c"
        "europe-west1-b" "europe-west1-c" "europe-west1-d"
        "asia-east1-a" "asia-east1-b" "asia-east1-c"
    ]
}

# Complete GCP regions
def "nu-complete gcp regions" [] {
    [
        "us-central1" "us-east1" "us-west1" "us-west2" "us-west3" "us-west4"
        "europe-west1" "europe-west2" "europe-west3" "europe-west4"
        "asia-east1" "asia-east2" "asia-northeast1" "asia-northeast2"
        "asia-south1" "asia-southeast1" "australia-southeast1"
    ]
}

# ============================================================================
# Docker Completions
# ============================================================================

# Complete running docker container names
def "nu-complete docker containers" [] {
    ^docker ps --format '{{.Names}}' | lines | where $it != ""
}

# Complete all docker container names (including stopped)
def "nu-complete docker containers all" [] {
    ^docker ps -a --format '{{.Names}}' | lines | where $it != ""
}

# Complete docker image names
def "nu-complete docker images" [] {
    ^docker images --format '{{.Repository}}:{{.Tag}}' | lines | where $it != ""
}

# Complete docker networks
def "nu-complete docker networks" [] {
    ^docker network ls --format '{{.Name}}' | lines | where $it != ""
}

# Complete docker volumes
def "nu-complete docker volumes" [] {
    ^docker volume ls --format '{{.Name}}' | lines | where $it != ""
}

# ============================================================================
# Git Branch Completions
# ============================================================================

# Complete git branches
def "nu-complete git branches" [] {
    ^git branch --format='%(refname:short)' | lines | where $it != ""
}

# Complete git remote branches
def "nu-complete git remote branches" [] {
    ^git branch -r --format='%(refname:short)' | lines | each { str replace 'origin/' '' } | where $it != ""
}

# Complete git remotes
def "nu-complete git remotes" [] {
    ^git remote | lines | where $it != ""
}

# Complete git tags
def "nu-complete git tags" [] {
    ^git tag | lines | where $it != ""
}

# ============================================================================
# Custom Commands with Completions
# ============================================================================

# Kubectl use context with completion
export def "kubectl-use-context" [context: string@"nu-complete kube contexts"] {
    kubectl config use-context $context
}

# Kubectl set namespace with completion
export def "kubectl-set-namespace" [namespace: string@"nu-complete kube namespaces"] {
    kubectl config set-context --current --namespace=$namespace
}

# Terraform workspace select with completion
export def "tf-workspace-select" [workspace: string@"nu-complete tf workspaces"] {
    terraform workspace select $workspace
}

# AWS set profile with completion
export def "aws-use-profile" [profile: string@"nu-complete aws profiles"] {
    $env.AWS_PROFILE = $profile
    print $"AWS profile set to: ($profile)"
}

# AWS set region with completion
export def "aws-use-region" [region: string@"nu-complete aws regions"] {
    $env.AWS_REGION = $region
    $env.AWS_DEFAULT_REGION = $region
    print $"AWS region set to: ($region)"
}

# GCP set project with completion
export def "gcp-use-project" [project: string@"nu-complete gcp projects"] {
    gcloud config set project $project
}

# Docker exec with container completion
export def "docker-exec-complete" [
    container: string@"nu-complete docker containers"
    shell: string = "sh"
] {
    docker exec -it $container $shell
}

# Docker logs with container completion
export def "docker-logs-complete" [
    container: string@"nu-complete docker containers"
    --follow (-f)
] {
    if $follow {
        docker logs -f $container
    } else {
        docker logs $container
    }
}

# Git checkout branch with completion
export def "git-checkout-branch" [branch: string@"nu-complete git branches"] {
    git checkout $branch
}

# Git merge branch with completion
export def "git-merge-branch" [branch: string@"nu-complete git branches"] {
    git merge $branch
}

# ============================================================================
# Enhanced External Completer (combines carapace with custom completers)
# ============================================================================

# Only set up if carapace is not already configured via vendor autoload
if (which carapace | is-not-empty) {
    # Custom completer that combines carapace with our specialized completers
    let custom_completer = {|spans: list<string>|
        # Match specific commands to use custom completers
        match $spans.0 {
            "kubectl" | "k" => {
                # Use kubectl's built-in completions
                ^kubectl completion nushell | nu-complete
            }
            _ => {
                # Fall back to carapace for everything else
                carapace $spans.0 nushell ...$spans
                | from json
                | if ($in | default [] | where value =~ '^-.*ERR$' | is-empty) { $in } else { null }
            }
        }
    }

    # Note: This will override carapace setup from 02-integrations.nu if needed
    # Uncomment the lines below if you want to use the custom completer
    # $env.config.completions.external = {
    #     enable: true
    #     max_results: 100
    #     completer: $custom_completer
    # }
}

# ============================================================================
# FZF-based Interactive Selectors
# ============================================================================

# Interactive kubectl context selector
export def kctx-fzf [] {
    if (which fzf | is-empty) {
        print "Error: fzf not installed"
        return
    }

    let context = (kubectl config get-contexts -o name | lines | fzf)
    if ($context | is-not-empty) {
        kubectl config use-context $context
    }
}

# Interactive kubectl namespace selector
export def kns-fzf [] {
    if (which fzf | is-empty) {
        print "Error: fzf not installed"
        return
    }

    let namespace = (kubectl get namespaces -o jsonpath='{.items[*].metadata.name}' | split row ' ' | fzf)
    if ($namespace | is-not-empty) {
        kubectl config set-context --current --namespace=$namespace
    }
}

# Interactive AWS profile selector
export def aws-profile-fzf [] {
    if (which fzf | is-empty) {
        print "Error: fzf not installed"
        return
    }

    let profile = (nu-complete aws profiles | to text | fzf)
    if ($profile | is-not-empty) {
        $env.AWS_PROFILE = $profile
        print $"AWS profile set to: ($profile)"
    }
}

# Interactive GCP project selector
export def gcp-project-fzf [] {
    if (which fzf | is-empty) {
        print "Error: fzf not installed"
        return
    }

    let project = (gcloud projects list --format='value(projectId)' | lines | fzf)
    if ($project | is-not-empty) {
        gcloud config set project $project
    }
}

# Interactive terraform workspace selector
export def tf-workspace-fzf [] {
    if (which fzf | is-empty) {
        print "Error: fzf not installed"
        return
    }

    let workspace = (terraform workspace list | lines | each { str trim | str replace '*' '' | str trim } | fzf)
    if ($workspace | is-not-empty) {
        terraform workspace select $workspace
    }
}

# Interactive docker container selector
export def docker-exec-fzf [shell: string = "sh"] {
    if (which fzf | is-empty) {
        print "Error: fzf not installed"
        return
    }

    let container = (docker ps --format '{{.Names}}' | lines | fzf)
    if ($container | is-not-empty) {
        docker exec -it $container $shell
    }
}
