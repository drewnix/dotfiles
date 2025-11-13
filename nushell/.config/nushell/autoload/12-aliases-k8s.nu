# ╔══════════════════════════════════════════════════════════════╗
# ║ Kubernetes Aliases & Commands                                ║
# ╚══════════════════════════════════════════════════════════════╝

# Main kubectl commands
export alias k = kubectl
export alias kl = kubectl logs
export alias klf = kubectl logs -f
export alias kexec = kubectl exec -it
export alias kpf = kubectl port-forward
export alias kaci = kubectl auth can-i
export alias kat = kubectl attach
export alias kapir = kubectl api-resources
export alias kapiv = kubectl api-versions
export alias kap = kubectl apply -f
export alias kdel = kubectl delete
export alias krun = kubectl run
export alias kcp = kubectl cp

# Get resources
export alias kg = kubectl get
export alias kga = kubectl get all
export alias kgaa = kubectl get all -A
export alias kgns = kubectl get ns
export alias kgp = kubectl get pods
export alias kgpa = kubectl get pods -A
export alias kgpw = kubectl get pods -o wide
export alias kgs = kubectl get secrets
export alias kgd = kubectl get deploy
export alias kgrs = kubectl get rs
export alias kgss = kubectl get sts
export alias kgds = kubectl get ds
export alias kgcm = kubectl get configmap
export alias kgcj = kubectl get cronjob
export alias kgj = kubectl get job
export alias kgsvc = kubectl get svc -o wide
export alias kgn = kubectl get no -o wide
export alias kgr = kubectl get roles
export alias kgrb = kubectl get rolebindings
export alias kgcr = kubectl get clusterroles
export alias kgcrb = kubectl get clusterrolebindings
export alias kgsa = kubectl get sa
export alias kgnet = kubectl get netpol
export alias kgi = kubectl get ingress
export alias kgpvc = kubectl get pvc
export alias kgpv = kubectl get pv
export alias kgev = kubectl get events --sort-by=.metadata.creationTimestamp

# Edit resources
export alias ke = kubectl edit
export alias kens = kubectl edit ns
export alias kes = kubectl edit secrets
export alias ked = kubectl edit deploy
export alias kers = kubectl edit rs
export alias kess = kubectl edit sts
export alias keds = kubectl edit ds
export alias kesvc = kubectl edit svc
export alias kecm = kubectl edit cm
export alias kecj = kubectl edit cj
export alias ker = kubectl edit roles
export alias kerb = kubectl edit rolebindings
export alias kecr = kubectl edit clusterroles
export alias kecrb = kubectl edit clusterrolebindings
export alias kesa = kubectl edit sa
export alias kenet = kubectl edit netpol

# Describe resources
export alias kd = kubectl describe
export alias kdns = kubectl describe ns
export alias kdp = kubectl describe pod
export alias kds = kubectl describe secrets
export alias kdd = kubectl describe deploy
export alias kdrs = kubectl describe rs
export alias kdss = kubectl describe sts
export alias kdds = kubectl describe ds
export alias kdsvc = kubectl describe svc
export alias kdcm = kubectl describe cm
export alias kdcj = kubectl describe cj
export alias kdj = kubectl describe job
export alias kdsa = kubectl describe sa
export alias kdr = kubectl describe roles
export alias kdrb = kubectl describe rolebindings
export alias kdcr = kubectl describe clusterroles
export alias kdcrb = kubectl describe clusterrolebindings
export alias kdnet = kubectl describe netpol
export alias kdn = kubectl describe node

# Delete resources
export alias kdelns = kubectl delete ns
export alias kdels = kubectl delete secrets
export alias kdelp = kubectl delete po
export alias kdeld = kubectl delete deployment
export alias kdelrs = kubectl delete rs
export alias kdelss = kubectl delete sts
export alias kdelds = kubectl delete ds
export alias kdelsvc = kubectl delete svc
export alias kdelcm = kubectl delete cm
export alias kdelcj = kubectl delete cj
export alias kdelj = kubectl delete job
export alias kdelr = kubectl delete roles
export alias kdelrb = kubectl delete rolebindings
export alias kdelcr = kubectl delete clusterroles
export alias kdelcrb = kubectl delete clusterrolebindings
export alias kdelsa = kubectl delete sa
export alias kdelnet = kubectl delete netpol

# Dry run/mock resources
export alias kmock = kubectl create -o yaml --dry-run=client
export alias kmockns = kubectl create ns mock -o yaml --dry-run=client
export alias kmockcm = kubectl create cm mock -o yaml --dry-run=client
export alias kmocksa = kubectl create sa mock -o yaml --dry-run=client

# Config/context management
export alias kcfg = kubectl config
export alias kcfgv = kubectl config view
export alias kcfgns = kubectl config set-context --current --namespace
export alias kcfgcurrent = kubectl config current-context
export alias kcfggc = kubectl config get-contexts
export alias kcfgsc = kubectl config set-context
export alias kcfguc = kubectl config use-context
export alias kctx = kubectl config use-context
export alias kns = kubectl config set-context --current --namespace

# Kubescape security scanning
export alias kssbom = kubectl -n kubescape get sbomspdxv2p3s
export alias kssbomf = kubectl -n kubescape get sbomspdxv2p3filtereds
export alias kssboms = kubectl -n kubescape get sbomsummaries
export alias ksvulns = kubectl -n kubescape get vulnerabilitymanifestsummaries
export alias ksvuln = kubectl -n kubescape get vulnerabilitymanifests
export alias kssboml = kubectl -n kubescape get sbomspdxv2p3s --show-labels
export alias kssbomfl = kubectl -n kubescape get sbomspdxv2p3filtereds --show-labels
export alias kssbomsl = kubectl -n kubescape get sbomsummaries --show-labels
export alias ksvulnsl = kubectl -n kubescape get vulnerabilitymanifestsummaries --show-labels
export alias ksvulnl = kubectl -n kubescape get vulnerabilitymanifests --show-labels

# Modern k8s tools (conditional aliases based on tool availability)

# kubectx/kubens - faster context/namespace switching
if (which kubectx | is-not-empty) {
  export alias kx = kubectx
  export alias kxp = kubectx -  # previous context
}

if (which kubens | is-not-empty) {
  export alias kn = kubens
  export alias knp = kubens -  # previous namespace
}

# k9s - terminal UI for kubernetes
if (which k9s | is-not-empty) {
  export alias k9 = k9s
  export alias k9r = k9s --readonly
}

# stern - multi-pod log tailing
if (which stern | is-not-empty) {
  export alias ks = stern
  export alias ksf = stern --tail 1
}

# helm - kubernetes package manager
if (which helm | is-not-empty) {
  export alias h = helm
  export alias hl = helm list
  export alias hla = helm list -A
  export alias hi = helm install
  export alias hu = helm upgrade
  export alias hd = helm delete
  export alias hs = helm search
  export alias hsh = helm show
}

# kustomize
if (which kustomize | is-not-empty) {
  export alias kz = kustomize
  export alias kzb = kustomize build
}

# ╔══════════════════════════════════════════════════════════════╗
# ║ Kubernetes Helper Commands                                   ║
# ╚══════════════════════════════════════════════════════════════╝

# Get pod logs by partial name match
export def klog [
  pattern: string              # Pod name pattern to search for
  namespace?: string           # Optional namespace
] {
  let ns_flag = if ($namespace | is-empty) {
    []
  } else {
    ["-n" $namespace]
  }

  let pods = (kubectl get pods ...$ns_flag -o name | lines | str replace "pod/" "" | where { |it| $it =~ $pattern })

  if ($pods | is-empty) {
    print $"(ansi red)No pod found matching: ($pattern)(ansi reset)"
    return
  }

  let pod = ($pods | first)
  print $"(ansi green)Tailing logs for: ($pod)(ansi reset)"
  kubectl logs -f $pod ...$ns_flag
}

# Exec into pod by partial name match
export def kexe [
  pattern: string              # Pod name pattern to search for
  namespace?: string           # Optional namespace
  shell?: string = "sh"        # Shell to use (default: sh)
] {
  let ns_flag = if ($namespace | is-empty) {
    []
  } else {
    ["-n" $namespace]
  }

  # Get pods, filter by pattern and Running status
  let pods_raw = (kubectl get pods ...$ns_flag -o json | from json)
  let running_pods = ($pods_raw.items
    | where { |pod|
        ($pod.metadata.name =~ $pattern) and ($pod.status.phase == "Running")
      }
    | get metadata.name)

  if ($running_pods | is-empty) {
    print $"(ansi red)No running pod found matching: ($pattern)(ansi reset)"
    return
  }

  let pod = ($running_pods | first)
  print $"(ansi green)Executing into: ($pod)(ansi reset)"
  kubectl exec -it $pod ...$ns_flag -- $shell
}

# Get all resources in a namespace
export def kgall [
  namespace: string = "default"  # Namespace to query (default: default)
] {
  print $"(ansi cyan)Getting all resources in namespace: ($namespace)(ansi reset)"
  kubectl get all,cm,secrets,ing,pvc,netpol -n $namespace
}

# Watch pods in current namespace
export def kwp [] {
  # Use external watch command (prefix with ^)
  ^watch -n 2 kubectl get pods
}

# Get pod resource usage
export def kresources [] {
  kubectl top pods --containers
}

# Quick context info
export def kinfo [] {
  let current_context = (kubectl config current-context | str trim)
  let current_ns = (kubectl config view --minify -o json
    | from json
    | get contexts.0.context.namespace?
    | default "default")
  let server = (kubectl config view --minify -o json
    | from json
    | get clusters.0.cluster.server)

  print $"(ansi cyan)Current Context:(ansi reset) ($current_context)"
  print $"(ansi cyan)Current Namespace:(ansi reset) ($current_ns)"
  print $"(ansi cyan)Server:(ansi reset) ($server)"
}

# Get pods with enhanced formatting using structured data
export def kgp-enhanced [
  namespace?: string  # Optional namespace
] {
  let ns_flag = if ($namespace | is-empty) {
    []
  } else {
    ["-n" $namespace]
  }

  kubectl get pods ...$ns_flag -o json
  | from json
  | get items
  | select metadata.name status.phase status.containerStatuses.0.restartCount? metadata.creationTimestamp
  | rename name phase restarts created
}

# Get all pods across all namespaces with enhanced formatting
export def kgpa-enhanced [] {
  kubectl get pods -A -o json
  | from json
  | get items
  | select metadata.namespace metadata.name status.phase status.containerStatuses.0.restartCount? metadata.creationTimestamp
  | rename namespace name phase restarts created
}

# Get pod by name pattern (returns structured data)
export def kfindpod [
  pattern: string      # Pod name pattern
  namespace?: string   # Optional namespace
] {
  let ns_flag = if ($namespace | is-empty) {
    []
  } else {
    ["-n" $namespace]
  }

  kubectl get pods ...$ns_flag -o json
  | from json
  | get items
  | where { |pod| $pod.metadata.name =~ $pattern }
  | select metadata.name metadata.namespace status.phase status.podIP
  | rename name namespace phase ip
}

# Get events for a specific pod
export def kpod-events [
  pod: string          # Pod name
  namespace?: string   # Optional namespace
] {
  let ns_flag = if ($namespace | is-empty) {
    []
  } else {
    ["-n" $namespace]
  }

  kubectl get events ...$ns_flag --field-selector involvedObject.name=$pod --sort-by=.metadata.creationTimestamp
}

# Get failed pods
export def kgp-failed [
  namespace?: string   # Optional namespace
] {
  let ns_flag = if ($namespace | is-empty) {
    ["-A"]
  } else {
    ["-n" $namespace]
  }

  kubectl get pods ...$ns_flag -o json
  | from json
  | get items
  | where { |pod| $pod.status.phase != "Running" and $pod.status.phase != "Succeeded" }
  | select metadata.namespace metadata.name status.phase status.containerStatuses.0.state
  | rename namespace name phase state
}

# Get pods sorted by restart count
export def kgp-restarts [
  namespace?: string   # Optional namespace
] {
  let ns_flag = if ($namespace | is-empty) {
    ["-A"]
  } else {
    ["-n" $namespace]
  }

  kubectl get pods ...$ns_flag -o json
  | from json
  | get items
  | select metadata.namespace metadata.name status.containerStatuses.0.restartCount?
  | rename namespace name restarts
  | where restarts != null
  | sort-by restarts --reverse
}

# Get deployments with replica info
export def kgd-enhanced [
  namespace?: string   # Optional namespace
] {
  let ns_flag = if ($namespace | is-empty) {
    []
  } else {
    ["-n" $namespace]
  }

  kubectl get deployments ...$ns_flag -o json
  | from json
  | get items
  | select metadata.name spec.replicas status.replicas status.readyReplicas? status.availableReplicas?
  | rename name desired current ready available
}

# Get services with endpoints
export def kgsvc-enhanced [
  namespace?: string   # Optional namespace
] {
  let ns_flag = if ($namespace | is-empty) {
    []
  } else {
    ["-n" $namespace]
  }

  kubectl get services ...$ns_flag -o json
  | from json
  | get items
  | select metadata.name spec.type spec.clusterIP spec.ports
  | rename name type cluster_ip ports
}

# Get nodes with resource info
export def kgn-enhanced [] {
  kubectl get nodes -o json
  | from json
  | get items
  | select metadata.name status.nodeInfo.kubeletVersion status.allocatable.cpu status.allocatable.memory
  | rename name version cpu memory
}

# Decode a secret
export def kdecode-secret [
  secret: string       # Secret name
  namespace?: string   # Optional namespace
] {
  let ns_flag = if ($namespace | is-empty) {
    []
  } else {
    ["-n" $namespace]
  }

  kubectl get secret $secret ...$ns_flag -o json
  | from json
  | get data
  | transpose key value
  | update value { |row| $row.value | decode base64 }
}

# Get all images used in a namespace
export def kget-images [
  namespace?: string = "default"  # Namespace to query
] {
  kubectl get pods -n $namespace -o json
  | from json
  | get items
  | get spec.containers
  | flatten
  | get image
  | uniq
  | sort
}

# Get all images across all namespaces
export def kget-images-all [] {
  kubectl get pods -A -o json
  | from json
  | get items
  | select metadata.namespace spec.containers
  | each { |pod|
      $pod.spec.containers
      | each { |container|
          {namespace: $pod.metadata.namespace, image: $container.image}
        }
    }
  | flatten
  | uniq
  | sort-by namespace image
}

# Get ConfigMaps with keys
export def kgcm-enhanced [
  namespace?: string   # Optional namespace
] {
  let ns_flag = if ($namespace | is-empty) {
    []
  } else {
    ["-n" $namespace]
  }

  kubectl get configmaps ...$ns_flag -o json
  | from json
  | get items
  | select metadata.name data
  | update data { |row| $row.data | transpose key value | get key }
  | rename name keys
}

# Get resource quotas and usage
export def kget-quota [
  namespace?: string   # Optional namespace
] {
  let ns_flag = if ($namespace | is-empty) {
    []
  } else {
    ["-n" $namespace]
  }

  kubectl get resourcequota ...$ns_flag -o json
  | from json
  | get items?
  | default []
  | select metadata.name status.hard status.used
  | rename name hard used
}

# Get persistent volume claims with capacity
export def kgpvc-enhanced [
  namespace?: string   # Optional namespace
] {
  let ns_flag = if ($namespace | is-empty) {
    []
  } else {
    ["-n" $namespace]
  }

  kubectl get pvc ...$ns_flag -o json
  | from json
  | get items
  | select metadata.name status.phase spec.volumeName status.capacity.storage?
  | rename name phase volume capacity
}

# Get pod logs for all containers in pod
export def klog-all [
  pod: string          # Pod name
  namespace?: string   # Optional namespace
] {
  let ns_flag = if ($namespace | is-empty) {
    []
  } else {
    ["-n" $namespace]
  }

  let containers = (kubectl get pod $pod ...$ns_flag -o json
    | from json
    | get spec.containers
    | get name)

  for container in $containers {
    print $"(ansi cyan)===== Logs for container: ($container) =====(ansi reset)"
    kubectl logs $pod -c $container ...$ns_flag
    print ""
  }
}

# Get previous logs for crashed pod
export def klog-previous [
  pattern: string      # Pod name pattern
  namespace?: string   # Optional namespace
] {
  let ns_flag = if ($namespace | is-empty) {
    []
  } else {
    ["-n" $namespace]
  }

  let pods = (kubectl get pods ...$ns_flag -o name | lines | str replace "pod/" "" | where { |it| $it =~ $pattern })

  if ($pods | is-empty) {
    print $"(ansi red)No pod found matching: ($pattern)(ansi reset)"
    return
  }

  let pod = ($pods | first)
  print $"(ansi green)Getting previous logs for: ($pod)(ansi reset)"
  kubectl logs $pod --previous ...$ns_flag
}

# Port-forward with common defaults
export def kpf-common [
  pattern: string      # Pod name pattern or service name
  port: int            # Port to forward
  namespace?: string   # Optional namespace
  local_port?: int     # Optional local port (defaults to same as remote)
] {
  let ns_flag = if ($namespace | is-empty) {
    []
  } else {
    ["-n" $namespace]
  }

  let port_mapping = if ($local_port | is-empty) {
    $"($port):($port)"
  } else {
    $"($local_port):($port)"
  }

  # Try to find as pod first
  let pods = (kubectl get pods ...$ns_flag -o name | lines | str replace "pod/" "" | where { |it| $it =~ $pattern })

  if ($pods | is-not-empty) {
    let pod = ($pods | first)
    print $"(ansi green)Port-forwarding to pod: ($pod) on ($port_mapping)(ansi reset)"
    kubectl port-forward $pod $port_mapping ...$ns_flag
  } else {
    # Try as service
    print $"(ansi green)Port-forwarding to service: ($pattern) on ($port_mapping)(ansi reset)"
    kubectl port-forward $"service/($pattern)" $port_mapping ...$ns_flag
  }
}

# List all contexts with current highlighted
export def kctx-list [] {
  kubectl config get-contexts
}

# Switch context interactively (requires fzf)
export def kctx-switch [] {
  if (which fzf | is-empty) {
    print $"(ansi red)fzf is required for interactive context switching(ansi reset)"
    return
  }

  let contexts = (kubectl config get-contexts -o name | lines)
  let selected = ($contexts | str join "\n" | fzf)

  if ($selected | is-not-empty) {
    kubectl config use-context $selected
    print $"(ansi green)Switched to context: ($selected)(ansi reset)"
  }
}

# Switch namespace interactively (requires fzf)
export def kns-switch [] {
  if (which fzf | is-empty) {
    print $"(ansi red)fzf is required for interactive namespace switching(ansi reset)"
    return
  }

  let namespaces = (kubectl get namespaces -o json | from json | get items.metadata.name)
  let selected = ($namespaces | str join "\n" | fzf)

  if ($selected | is-not-empty) {
    kubectl config set-context --current --namespace $selected
    print $"(ansi green)Switched to namespace: ($selected)(ansi reset)"
  }
}

# Get all pod names (useful for piping)
export def kget-pod-names [
  namespace?: string   # Optional namespace
] {
  let ns_flag = if ($namespace | is-empty) {
    []
  } else {
    ["-n" $namespace]
  }

  kubectl get pods ...$ns_flag -o json
  | from json
  | get items.metadata.name
}

# Get all namespace names
export def kget-namespaces [] {
  kubectl get namespaces -o json
  | from json
  | get items.metadata.name
}

# Rollout restart deployment
export def krestart [
  deployment: string   # Deployment name
  namespace?: string   # Optional namespace
] {
  let ns_flag = if ($namespace | is-empty) {
    []
  } else {
    ["-n" $namespace]
  }

  print $"(ansi cyan)Restarting deployment: ($deployment)(ansi reset)"
  kubectl rollout restart deployment $deployment ...$ns_flag
}

# Rollout status
export def krollout-status [
  deployment: string   # Deployment name
  namespace?: string   # Optional namespace
] {
  let ns_flag = if ($namespace | is-empty) {
    []
  } else {
    ["-n" $namespace]
  }

  kubectl rollout status deployment $deployment ...$ns_flag
}

# Rollout history
export def krollout-history [
  deployment: string   # Deployment name
  namespace?: string   # Optional namespace
] {
  let ns_flag = if ($namespace | is-empty) {
    []
  } else {
    ["-n" $namespace]
  }

  kubectl rollout history deployment $deployment ...$ns_flag
}

# Rollout undo
export def krollout-undo [
  deployment: string   # Deployment name
  namespace?: string   # Optional namespace
  revision?: int       # Optional revision to rollback to
] {
  let ns_flag = if ($namespace | is-empty) {
    []
  } else {
    ["-n" $namespace]
  }

  let rev_flag = if ($revision | is-empty) {
    []
  } else {
    ["--to-revision" ($revision | into string)]
  }

  kubectl rollout undo deployment $deployment ...$ns_flag ...$rev_flag
}

# Scale deployment
export def kscale [
  deployment: string   # Deployment name
  replicas: int        # Number of replicas
  namespace?: string   # Optional namespace
] {
  let ns_flag = if ($namespace | is-empty) {
    []
  } else {
    ["-n" $namespace]
  }

  print $"(ansi cyan)Scaling ($deployment) to ($replicas) replicas(ansi reset)"
  kubectl scale deployment $deployment --replicas $replicas ...$ns_flag
}

# Get all ingresses with hosts
export def kgi-enhanced [
  namespace?: string   # Optional namespace
] {
  let ns_flag = if ($namespace | is-empty) {
    []
  } else {
    ["-n" $namespace]
  }

  kubectl get ingress ...$ns_flag -o json
  | from json
  | get items
  | select metadata.name spec.rules
  | update rules { |row| $row.rules | get host }
  | rename name hosts
}

# Get cluster info
export def kcluster-info [] {
  print $"(ansi cyan)=== Cluster Info ===(ansi reset)"
  kubectl cluster-info

  print "\n(ansi cyan)=== Node Info ===(ansi reset)"
  kubectl get nodes -o wide

  print "\n(ansi cyan)=== Namespaces ===(ansi reset)"
  kubectl get namespaces

  print "\n(ansi cyan)=== API Versions ===(ansi reset)"
  kubectl api-versions | str trim
}

# Get top pods by CPU
export def ktop-cpu [
  namespace?: string   # Optional namespace
  limit: int = 10      # Number of results to show
] {
  let ns_flag = if ($namespace | is-empty) {
    ["-A"]
  } else {
    ["-n" $namespace]
  }

  kubectl top pods ...$ns_flag --no-headers
  | lines
  | parse "{namespace} {name} {cpu} {memory}"
  | update cpu { |row| $row.cpu | str replace 'm' '' | into int }
  | sort-by cpu --reverse
  | first $limit
}

# Get top pods by memory
export def ktop-memory [
  namespace?: string   # Optional namespace
  limit: int = 10      # Number of results to show
] {
  let ns_flag = if ($namespace | is-empty) {
    ["-A"]
  } else {
    ["-n" $namespace]
  }

  kubectl top pods ...$ns_flag --no-headers
  | lines
  | parse "{namespace} {name} {cpu} {memory}"
  | update memory { |row| $row.memory | str replace 'Mi' '' | into int }
  | sort-by memory --reverse
  | first $limit
}

# Get pods with high restart count
export def kpod-high-restarts [
  threshold: int = 5   # Restart count threshold
  namespace?: string   # Optional namespace
] {
  let ns_flag = if ($namespace | is-empty) {
    ["-A"]
  } else {
    ["-n" $namespace]
  }

  kubectl get pods ...$ns_flag -o json
  | from json
  | get items
  | select metadata.namespace metadata.name status.containerStatuses.0.restartCount?
  | rename namespace name restarts
  | where restarts != null and restarts >= $threshold
  | sort-by restarts --reverse
}

# Check if pods are ready
export def kpod-ready [
  namespace?: string   # Optional namespace
] {
  let ns_flag = if ($namespace | is-empty) {
    ["-A"]
  } else {
    ["-n" $namespace]
  }

  kubectl get pods ...$ns_flag -o json
  | from json
  | get items
  | select metadata.namespace metadata.name status.conditions
  | update status.conditions { |row|
      $row.status.conditions
      | where type == "Ready"
      | get 0.status
    }
  | rename namespace name ready
}

# Apply a manifest and wait for rollout
export def kapply-wait [
  file: string         # Manifest file to apply
  timeout: string = "5m"  # Timeout for rollout
] {
  print $"(ansi cyan)Applying manifest: ($file)(ansi reset)"
  kubectl apply -f $file

  # Get deployment name from file if it's a deployment
  let resources = (kubectl apply -f $file --dry-run=client -o json | from json)

  if ($resources.kind == "Deployment") {
    print $"(ansi cyan)Waiting for rollout to complete...(ansi reset)"
    kubectl rollout status deployment $resources.metadata.name -n $resources.metadata.namespace --timeout $timeout
  }
}

# Delete all resources in a namespace (dangerous!)
export def kdel-all-in-ns [
  namespace: string    # Namespace to clean
  --confirm            # Confirmation flag
] {
  if not $confirm {
    print $"(ansi yellow)Warning: This will delete ALL resources in namespace ($namespace)(ansi reset)"
    print $"(ansi yellow)Run with --confirm to proceed(ansi reset)"
    return
  }

  print $"(ansi red)Deleting all resources in namespace: ($namespace)(ansi reset)"
  kubectl delete all --all -n $namespace
}

# Get container images with tags
export def kget-container-info [
  namespace?: string   # Optional namespace
] {
  let ns_flag = if ($namespace | is-empty) {
    ["-A"]
  } else {
    ["-n" $namespace]
  }

  kubectl get pods ...$ns_flag -o json
  | from json
  | get items
  | each { |pod|
      $pod.spec.containers
      | each { |container|
          {
            namespace: $pod.metadata.namespace,
            pod: $pod.metadata.name,
            container: $container.name,
            image: $container.image,
            pull_policy: $container.imagePullPolicy?
          }
        }
    }
  | flatten
}

# Check for deprecated API versions
export def kcheck-deprecated [] {
  print $"(ansi cyan)Checking for deprecated API versions...(ansi reset)"
  kubectl get --raw /apis | from json | get groups | get name | sort
}

# Cordon a node (mark unschedulable)
export def kcordon [
  node: string         # Node name
] {
  print $"(ansi yellow)Cordoning node: ($node)(ansi reset)"
  kubectl cordon $node
}

# Uncordon a node (mark schedulable)
export def kuncordon [
  node: string         # Node name
] {
  print $"(ansi green)Uncordoning node: ($node)(ansi reset)"
  kubectl uncordon $node
}

# Drain a node
export def kdrain [
  node: string         # Node name
  --ignore-daemonsets  # Ignore DaemonSet-managed pods
  --delete-emptydir-data  # Delete pods using emptyDir
  --force              # Force drain
] {
  mut flags = []

  if $ignore_daemonsets {
    $flags = ($flags | append "--ignore-daemonsets")
  }

  if $delete_emptydir_data {
    $flags = ($flags | append "--delete-emptydir-data")
  }

  if $force {
    $flags = ($flags | append "--force")
  }

  print $"(ansi yellow)Draining node: ($node)(ansi reset)"
  kubectl drain $node ...$flags
}

# Get service accounts with secrets
export def kgsa-enhanced [
  namespace?: string   # Optional namespace
] {
  let ns_flag = if ($namespace | is-empty) {
    []
  } else {
    ["-n" $namespace]
  }

  kubectl get serviceaccounts ...$ns_flag -o json
  | from json
  | get items
  | select metadata.name secrets?
  | update secrets { |row|
      if ($row.secrets | is-empty) {
        []
      } else {
        $row.secrets | get name
      }
    }
  | rename name secrets
}

# Get role bindings for a service account
export def kget-sa-roles [
  service_account: string  # Service account name
  namespace?: string       # Optional namespace
] {
  let ns_flag = if ($namespace | is-empty) {
    []
  } else {
    ["-n" $namespace]
  }

  print $"(ansi cyan)Role Bindings:(ansi reset)"
  kubectl get rolebindings ...$ns_flag -o json
  | from json
  | get items
  | where { |rb|
      $rb.subjects?
      | default []
      | any { |s| $s.kind == "ServiceAccount" and $s.name == $service_account }
    }
  | select metadata.name roleRef.name
  | rename binding role

  print "\n(ansi cyan)Cluster Role Bindings:(ansi reset)"
  kubectl get clusterrolebindings -o json
  | from json
  | get items
  | where { |crb|
      $crb.subjects?
      | default []
      | any { |s| $s.kind == "ServiceAccount" and $s.name == $service_account }
    }
  | select metadata.name roleRef.name
  | rename binding role
}

# Get network policies
export def kgnet-enhanced [
  namespace?: string   # Optional namespace
] {
  let ns_flag = if ($namespace | is-empty) {
    []
  } else {
    ["-n" $namespace]
  }

  kubectl get networkpolicies ...$ns_flag -o json
  | from json
  | get items
  | select metadata.name spec.podSelector spec.policyTypes
  | rename name pod_selector policy_types
}

# Quick debug pod
export def kdebug [
  name: string = "debug-pod"  # Debug pod name
  namespace?: string          # Optional namespace
  image: string = "nicolaka/netshoot"  # Debug image
] {
  let ns_flag = if ($namespace | is-empty) {
    []
  } else {
    ["-n" $namespace]
  }

  print $"(ansi cyan)Creating debug pod: ($name)(ansi reset)"
  kubectl run $name --image=$image -it --rm ...$ns_flag -- /bin/bash
}

# Debug a specific pod by attaching ephemeral container
export def kdebug-pod [
  pod: string          # Pod to debug
  namespace?: string   # Optional namespace
  image: string = "nicolaka/netshoot"  # Debug image
] {
  let ns_flag = if ($namespace | is-empty) {
    []
  } else {
    ["-n" $namespace]
  }

  print $"(ansi cyan)Attaching debug container to pod: ($pod)(ansi reset)"
  kubectl debug $pod -it --image=$image ...$ns_flag
}

# Copy files from pod
export def kcp-from [
  pod: string          # Pod name
  remote_path: string  # Remote file/directory path
  local_path: string   # Local destination path
  namespace?: string   # Optional namespace
] {
  let ns_flag = if ($namespace | is-empty) {
    []
  } else {
    ["-n" $namespace]
  }

  let source = $"($pod):($remote_path)"
  print $"(ansi cyan)Copying from ($source) to ($local_path)(ansi reset)"
  kubectl cp $source $local_path ...$ns_flag
}

# Copy files to pod
export def kcp-to [
  local_path: string   # Local file/directory path
  pod: string          # Pod name
  remote_path: string  # Remote destination path
  namespace?: string   # Optional namespace
] {
  let ns_flag = if ($namespace | is-empty) {
    []
  } else {
    ["-n" $namespace]
  }

  let destination = $"($pod):($remote_path)"
  print $"(ansi cyan)Copying from ($local_path) to ($destination)(ansi reset)"
  kubectl cp $local_path $destination ...$ns_flag
}

# Watch resource continuously
export def kwatch [
  resource: string     # Resource type (e.g., pods, deployments)
  namespace?: string   # Optional namespace
] {
  let ns_flag = if ($namespace | is-empty) {
    []
  } else {
    ["-n" $namespace]
  }

  kubectl get $resource ...$ns_flag --watch
}

# Get all CRDs (Custom Resource Definitions)
export def kget-crds [] {
  kubectl get crds -o json
  | from json
  | get items
  | select metadata.name spec.group spec.versions
  | update spec.versions { |row| $row.spec.versions | get name }
  | rename name group versions
}

# Get custom resources of a specific CRD
export def kget-cr [
  crd: string          # CRD name
  namespace?: string   # Optional namespace
] {
  let ns_flag = if ($namespace | is-empty) {
    ["-A"]
  } else {
    ["-n" $namespace]
  }

  kubectl get $crd ...$ns_flag -o json
  | from json
  | get items
  | select metadata.namespace? metadata.name
}

# Verify pod connectivity
export def ktest-connectivity [
  pod: string          # Source pod name
  target: string       # Target (hostname/IP)
  namespace?: string   # Optional namespace
] {
  let ns_flag = if ($namespace | is-empty) {
    []
  } else {
    ["-n" $namespace]
  }

  print $"(ansi cyan)Testing connectivity from ($pod) to ($target)(ansi reset)"
  kubectl exec $pod ...$ns_flag -- ping -c 3 $target
}

# Get all finalizers on resources
export def kget-finalizers [
  namespace?: string   # Optional namespace
] {
  let ns_flag = if ($namespace | is-empty) {
    ["-A"]
  } else {
    ["-n" $namespace]
  }

  kubectl get all ...$ns_flag -o json
  | from json
  | get items
  | where { |item| ($item.metadata.finalizers? | default [] | is-not-empty) }
  | select kind metadata.namespace? metadata.name metadata.finalizers
  | rename kind namespace name finalizers
}

# Force delete pod (remove finalizers)
export def kforce-delete-pod [
  pod: string          # Pod name
  namespace?: string   # Optional namespace
] {
  let ns_flag = if ($namespace | is-empty) {
    []
  } else {
    ["-n" $namespace]
  }

  print $"(ansi yellow)Force deleting pod: ($pod)(ansi reset)"
  kubectl delete pod $pod ...$ns_flag --grace-period=0 --force
}

# Get pod security context
export def kget-security-context [
  pod: string          # Pod name
  namespace?: string   # Optional namespace
] {
  let ns_flag = if ($namespace | is-empty) {
    []
  } else {
    ["-n" $namespace]
  }

  kubectl get pod $pod ...$ns_flag -o json
  | from json
  | select spec.securityContext? spec.containers
  | update spec.containers { |row|
      $row.spec.containers
      | select name securityContext?
    }
}
