# ╔══════════════════════════════════════════════════════════════╗
# ║ Kubernetes Aliases & Functions                               ║
# ╚══════════════════════════════════════════════════════════════╝

# Main kubectl commands
alias k='kubectl'
alias kl='kubectl logs'
alias klf='kubectl logs -f'
alias kexec='kubectl exec -it'
alias kpf='kubectl port-forward'
alias kaci='kubectl auth can-i'
alias kat='kubectl attach'
alias kapir='kubectl api-resources'
alias kapiv='kubectl api-versions'
alias kap='kubectl apply -f'
alias kdel='kubectl delete'
alias krun='kubectl run'
alias kcp='kubectl cp'

# Get resources
alias kg='kubectl get'
alias kga='kubectl get all'
alias kgaa='kubectl get all -A'
alias kgns='kubectl get ns'
alias kgp='kubectl get pods'
alias kgpa='kubectl get pods -A'
alias kgpw='kubectl get pods -o wide'
alias kgs='kubectl get secrets'
alias kgd='kubectl get deploy'
alias kgrs='kubectl get rs'
alias kgss='kubectl get sts'
alias kgds='kubectl get ds'
alias kgcm='kubectl get configmap'
alias kgcj='kubectl get cronjob'
alias kgj='kubectl get job'
alias kgsvc='kubectl get svc -o wide'
alias kgn='kubectl get no -o wide'
alias kgr='kubectl get roles'
alias kgrb='kubectl get rolebindings'
alias kgcr='kubectl get clusterroles'
alias kgcrb='kubectl get clusterrolebindings'
alias kgsa='kubectl get sa'
alias kgnet='kubectl get netpol'
alias kgi='kubectl get ingress'
alias kgpvc='kubectl get pvc'
alias kgpv='kubectl get pv'
alias kgev='kubectl get events --sort-by=.metadata.creationTimestamp'

# Edit resources
alias ke='kubectl edit'
alias kens='kubectl edit ns'
alias kes='kubectl edit secrets'
alias ked='kubectl edit deploy'
alias kers='kubectl edit rs'
alias kess='kubectl edit sts'
alias keds='kubectl edit ds'
alias kesvc='kubectl edit svc'
alias kecm='kubectl edit cm'
alias kecj='kubectl edit cj'
alias ker='kubectl edit roles'
alias kerb='kubectl edit rolebindings'
alias kecr='kubectl edit clusterroles'
alias kecrb='kubectl edit clusterrolebindings'
alias kesa='kubectl edit sa'
alias kenet='kubectl edit netpol'

# Describe resources
alias kd='kubectl describe'
alias kdns='kubectl describe ns'
alias kdp='kubectl describe pod'
alias kds='kubectl describe secrets'
alias kdd='kubectl describe deploy'
alias kdrs='kubectl describe rs'
alias kdss='kubectl describe sts'
alias kdds='kubectl describe ds'
alias kdsvc='kubectl describe svc'
alias kdcm='kubectl describe cm'
alias kdcj='kubectl describe cj'
alias kdj='kubectl describe job'
alias kdsa='kubectl describe sa'
alias kdr='kubectl describe roles'
alias kdrb='kubectl describe rolebindings'
alias kdcr='kubectl describe clusterroles'
alias kdcrb='kubectl describe clusterrolebindings'
alias kdnet='kubectl describe netpol'
alias kdn='kubectl describe node'

# Delete resources
alias kdelns='kubectl delete ns'
alias kdels='kubectl delete secrets'
alias kdelp='kubectl delete po'
alias kdeld='kubectl delete deployment'
alias kdelrs='kubectl delete rs'
alias kdelss='kubectl delete sts'
alias kdelds='kubectl delete ds'
alias kdelsvc='kubectl delete svc'
alias kdelcm='kubectl delete cm'
alias kdelcj='kubectl delete cj'
alias kdelj='kubectl delete job'
alias kdelr='kubectl delete roles'
alias kdelrb='kubectl delete rolebindings'
alias kdelcr='kubectl delete clusterroles'
alias kdelcrb='kubectl delete clusterrolebindings'
alias kdelsa='kubectl delete sa'
alias kdelnet='kubectl delete netpol'

# Dry run/mock resources
alias kmock='kubectl create -o yaml --dry-run=client'
alias kmockns='kubectl create ns mock -o yaml --dry-run=client'
alias kmockcm='kubectl create cm mock -o yaml --dry-run=client'
alias kmocksa='kubectl create sa mock -o yaml --dry-run=client'

# Config/context management
alias kcfg='kubectl config'
alias kcfgv='kubectl config view'
alias kcfgns='kubectl config set-context --current --namespace'
alias kcfgcurrent='kubectl config current-context'
alias kcfggc='kubectl config get-contexts'
alias kcfgsc='kubectl config set-context'
alias kcfguc='kubectl config use-context'
alias kctx='kubectl config use-context'
alias kns='kubectl config set-context --current --namespace'

# Kubescape security scanning
alias kssbom='kubectl -n kubescape get sbomspdxv2p3s'
alias kssbomf='kubectl -n kubescape get sbomspdxv2p3filtereds'
alias kssboms='kubectl -n kubescape get sbomsummaries'
alias ksvulns='kubectl -n kubescape get vulnerabilitymanifestsummaries'
alias ksvuln='kubectl -n kubescape get vulnerabilitymanifests'
alias kssboml='kubectl -n kubescape get sbomspdxv2p3s --show-labels'
alias kssbomfl='kubectl -n kubescape get sbomspdxv2p3filtereds --show-labels'
alias kssbomsl='kubectl -n kubescape get sbomsummaries --show-labels'
alias ksvulnsl='kubectl -n kubescape get vulnerabilitymanifestsummaries --show-labels'
alias ksvulnl='kubectl -n kubescape get vulnerabilitymanifests --show-labels'

# Modern k8s tools (if installed)
# kubectx/kubens - faster context/namespace switching
if command -v kubectx &> /dev/null; then
  alias kx='kubectx'
  alias kxp='kubectx -'  # previous context
fi

if command -v kubens &> /dev/null; then
  alias kn='kubens'
  alias knp='kubens -'  # previous namespace
fi

# k9s - terminal UI for kubernetes
if command -v k9s &> /dev/null; then
  alias k9='k9s'
  alias k9r='k9s --readonly'
fi

# stern - multi-pod log tailing
if command -v stern &> /dev/null; then
  alias ks='stern'
  alias ksf='stern --tail 1'
fi

# helm - kubernetes package manager
if command -v helm &> /dev/null; then
  alias h='helm'
  alias hl='helm list'
  alias hla='helm list -A'
  alias hi='helm install'
  alias hu='helm upgrade'
  alias hd='helm delete'
  alias hs='helm search'
  alias hsh='helm show'
fi

# kustomize
if command -v kustomize &> /dev/null; then
  alias kz='kustomize'
  alias kzb='kustomize build'
fi

# ╔══════════════════════════════════════════════════════════════╗
# ║ Kubernetes Helper Functions                                  ║
# ╚══════════════════════════════════════════════════════════════╝

# Get pod logs by partial name match
klog() {
  if [ -z "$1" ]; then
    echo "Usage: klog <pod-name-pattern> [namespace]"
    return 1
  fi

  local ns_flag=""
  if [ -n "$2" ]; then
    ns_flag="-n $2"
  fi

  local pod=$(kubectl get pods $ns_flag | grep "$1" | head -1 | awk '{print $1}')
  if [ -z "$pod" ]; then
    echo "No pod found matching: $1"
    return 1
  fi

  echo "Tailing logs for: $pod"
  kubectl logs -f $pod $ns_flag
}

# Exec into pod by partial name match
kexe() {
  if [ -z "$1" ]; then
    echo "Usage: kexe <pod-name-pattern> [namespace] [shell]"
    return 1
  fi

  local ns_flag=""
  if [ -n "$2" ]; then
    ns_flag="-n $2"
  fi

  local shell="${3:-sh}"

  local pod=$(kubectl get pods $ns_flag | grep "$1" | grep Running | head -1 | awk '{print $1}')
  if [ -z "$pod" ]; then
    echo "No running pod found matching: $1"
    return 1
  fi

  echo "Executing into: $pod"
  kubectl exec -it $pod $ns_flag -- $shell
}

# Get all resources in a namespace
kgall() {
  local ns="${1:-default}"
  echo "Getting all resources in namespace: $ns"
  kubectl get all,cm,secrets,ing,pvc,netpol -n $ns
}

# Watch pods in current namespace
kwp() {
  watch -n 2 kubectl get pods
}

# Get pod resource usage
kresources() {
  kubectl top pods --containers
}

# Quick context info
kinfo() {
  echo "Current Context: $(kubectl config current-context)"
  echo "Current Namespace: $(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null || echo 'default')"
  echo "Server: $(kubectl config view --minify --output 'jsonpath={.clusters[0].cluster.server}')"
}
