# ╔══════════════════════════════════════════════════════════════╗
# ║ Security & Scanning Aliases                                  ║
# ╚══════════════════════════════════════════════════════════════╝
#
# Aliases for security scanning, vulnerability detection, and
# infrastructure analysis tools.

# ╔══════════════════════════════════════════════════════════════╗
# ║ Trivy - Security Scanner                                     ║
# ╚══════════════════════════════════════════════════════════════╝

# Container image scanning
alias trscan='trivy image'                                  # Scan container image
alias trscan-high='trivy image --severity HIGH,CRITICAL'    # Only HIGH/CRITICAL vulns
alias trscan-json='trivy image -f json'                     # JSON output
alias trscan-table='trivy image -f table'                   # Table output (default)

# Infrastructure as Code scanning
alias trconfig='trivy config'                               # Scan IaC (Terraform, K8s)
alias trtf='trivy config ./terraform'                       # Scan Terraform
alias trk8s='trivy config ./k8s'                            # Scan K8s manifests
alias trhelm='trivy config'                                 # Scan Helm charts

# Filesystem scanning
alias trfs='trivy fs'                                       # Scan filesystem
alias trfs-vuln='trivy fs --scanners vuln'                  # Only vulnerabilities
alias trfs-secret='trivy fs --scanners secret'              # Only secrets
alias trfs-all='trivy fs --scanners vuln,secret,misconfig'  # All scanners

# Repository scanning
alias trrepo='trivy repo'                                   # Scan Git repository
alias trrepo-remote='trivy repo'                            # Scan remote repo

# ╔══════════════════════════════════════════════════════════════╗
# ║ Terraform Security Tools                                     ║
# ╚══════════════════════════════════════════════════════════════╝

# tfsec - Terraform security scanner
alias tfsec='tfsec'                                         # Scan current directory
alias tfsec-json='tfsec --format json'                      # JSON output
alias tfsec-sarif='tfsec --format sarif'                    # SARIF output (for GitHub)
alias tfsec-soft='tfsec --soft-fail'                        # Don't exit with error
alias tfsec-high='tfsec --severity HIGH,CRITICAL'           # Only serious issues
alias tfsec-ignore='tfsec --exclude-downloaded-modules'     # Skip vendor modules

# tflint - Terraform linter
alias tfl='tflint'                                          # Lint current directory
alias tflinit='tflint --init'                               # Initialize plugins
alias tflr='tflint --recursive'                             # Lint recursively
alias tflfix='tflint --fix'                                 # Auto-fix issues (if available)
alias tflaws='tflint --enable-rule=terraform_naming_convention' # AWS naming rules

# Combined Terraform security check
alias tfseccheck='tflint && tfsec'                          # Run both linters

# ╔══════════════════════════════════════════════════════════════╗
# ║ Dive - Docker Image Analysis                                ║
# ╚══════════════════════════════════════════════════════════════╝

alias dive='dive'                                           # Analyze Docker image
alias diveci='CI=true dive'                                 # CI mode (exit on inefficiency)

# ╔══════════════════════════════════════════════════════════════╗
# ║ yq - YAML Processor                                         ║
# ╚══════════════════════════════════════════════════════════════╝

alias yq='yq'                                               # YAML processor
alias yqe='yq eval'                                         # Evaluate expression
alias yqei='yq eval -i'                                     # Evaluate in-place
alias yqjson='yq eval -o=json'                              # Convert to JSON
alias yqxml='yq eval -o=xml'                                # Convert to XML
alias yqprops='yq eval -o=props'                            # Convert to properties

# ╔══════════════════════════════════════════════════════════════╗
# ║ Kubernetes Security & Observability                         ║
# ╚══════════════════════════════════════════════════════════════╝

# kubetail - multi-pod log tailing
alias kt='kubetail'                                         # Tail logs from multiple pods
alias ktf='kubetail -f'                                     # Follow logs
alias kts='kubetail --timestamps'                           # Show timestamps

# popeye - cluster sanitizer
alias kpop='popeye'                                         # Scan cluster
alias kpop-save='popeye --save'                             # Save report
alias kpop-json='popeye --output json'                      # JSON output
alias kpop-html='popeye --output html'                      # HTML report

# kube-capacity - resource analysis
alias kcap='kube-capacity'                                  # Show capacity
alias kcap-util='kube-capacity --util'                      # Include utilization
alias kcap-pods='kube-capacity --pods'                      # Show pod breakdowns
alias kcap-json='kube-capacity -o json'                     # JSON output

# krew - kubectl plugin manager
alias krew='kubectl krew'                                   # Krew command
alias krew-search='kubectl krew search'                     # Search plugins
alias krew-install='kubectl krew install'                   # Install plugin
alias krew-list='kubectl krew list'                         # List installed
alias krew-update='kubectl krew update'                     # Update plugin list
alias krew-upgrade='kubectl krew upgrade'                   # Upgrade plugins

# ╔══════════════════════════════════════════════════════════════╗
# ║ AWS Security                                                 ║
# ╚══════════════════════════════════════════════════════════════╝

# aws-vault - secure credential management
alias av='aws-vault'                                        # aws-vault shortcut
alias avl='aws-vault list'                                  # List profiles
alias avadd='aws-vault add'                                 # Add profile
alias avexec='aws-vault exec'                               # Execute with profile
alias avlogin='aws-vault login'                             # Browser login
alias avrotate='aws-vault rotate'                           # Rotate credentials
alias avrm='aws-vault remove'                               # Remove profile

# ╔══════════════════════════════════════════════════════════════╗
# ║ Steampipe - SQL for Cloud APIs                              ║
# ╚══════════════════════════════════════════════════════════════╝

# Core Steampipe commands
alias sp='steampipe query'                                  # Run query
alias sps='steampipe service start'                         # Start service
alias spx='steampipe service stop'                          # Stop service
alias spr='steampipe service restart'                       # Restart service
alias spstat='steampipe service status'                     # Service status
alias spplugin='steampipe plugin'                           # Plugin management
alias spinstall='steampipe plugin install'                  # Install plugins
alias spupdate='steampipe plugin update'                    # Update plugins

# Quick queries - AWS Security
alias sp-aws-mfa='steampipe query "select name, arn, mfa_enabled from aws_iam_user where password_enabled = true and mfa_enabled = false"'
alias sp-aws-s3='steampipe query "select name, region, bucket_policy_is_public from aws_s3_bucket where bucket_policy_is_public = true"'
alias sp-aws-sg='steampipe query "select group_name, vpc_id from aws_vpc_security_group where ip_permissions @> '\''[{\"FromPort\": 22}]'\'' or ip_permissions @> '\''[{\"FromPort\": 3389}]'\''"'
alias sp-aws-ebs='steampipe query "select volume_id, size, encrypted from aws_ebs_volume where encrypted = false"'
alias sp-aws-rds='steampipe query "select db_instance_identifier, storage_encrypted, publicly_accessible from aws_rds_db_instance where storage_encrypted = false"'

# Quick queries - Kubernetes
alias sp-k8s-pods='steampipe query "select name, namespace, phase from kubernetes_pod"'
alias sp-k8s-priv='steampipe query "select name, namespace from kubernetes_pod where host_network = true or host_pid = true or host_ipc = true"'
alias sp-k8s-root='steampipe query "select name, namespace from kubernetes_pod where pod_spec -> '\''securityContext'\'' ->> '\''runAsUser'\'' = '\''0'\''"'
alias sp-k8s-svc='steampipe query "select name, namespace, type from kubernetes_service where type = '\''LoadBalancer'\''"'

# Quick queries - Cost optimization
alias sp-cost-ebs='steampipe query "select volume_id, size, state from aws_ebs_volume where state = '\''available'\''"'
alias sp-cost-eip='steampipe query "select public_ip, allocation_id from aws_vpc_eip where association_id is null"'
alias sp-cost-elb='steampipe query "select load_balancer_name, type from aws_ec2_application_load_balancer"'

# Quick queries - Inventory
alias sp-inv-ec2='steampipe query "select instance_id, instance_type, instance_state, region from aws_ec2_instance"'
alias sp-inv-s3='steampipe query "select name, region, creation_date from aws_s3_bucket"'
alias sp-inv-rds='steampipe query "select db_instance_identifier, engine, db_instance_status from aws_rds_db_instance"'
alias sp-inv-k8s='steampipe query "select count(*) as pod_count, namespace from kubernetes_pod group by namespace order by pod_count desc"'

# ╔══════════════════════════════════════════════════════════════╗
# ║ Helper Functions                                             ║
# ╚══════════════════════════════════════════════════════════════╝

# Scan Docker image with all tools
scan-image() {
    local image=$1
    if [[ -z "$image" ]]; then
        echo "Usage: scan-image <image:tag>"
        echo "Scans a Docker image with trivy and analyzes with dive"
        return 1
    fi

    echo "📦 Analyzing image: $image"
    echo ""
    echo "🔍 Running Trivy security scan..."
    trivy image --severity HIGH,CRITICAL "$image"
    echo ""
    echo "📊 Running Dive layer analysis..."
    dive "$image"
}

# Scan Terraform directory
scan-terraform() {
    local dir=${1:-.}

    echo "🔍 Scanning Terraform in: $dir"
    echo ""

    if command -v tflint &> /dev/null; then
        echo "📝 Running tflint..."
        tflint --chdir="$dir"
        echo ""
    fi

    if command -v tfsec &> /dev/null; then
        echo "🔒 Running tfsec..."
        tfsec "$dir"
        echo ""
    fi

    if command -v trivy &> /dev/null; then
        echo "🛡️  Running trivy config scan..."
        trivy config "$dir"
    fi
}

# Scan Kubernetes manifests
scan-k8s() {
    local dir=${1:-./k8s}

    if [[ ! -d "$dir" ]]; then
        echo "Directory not found: $dir"
        return 1
    fi

    echo "🔍 Scanning Kubernetes manifests in: $dir"
    echo ""

    if command -v trivy &> /dev/null; then
        echo "🛡️  Running trivy config scan..."
        trivy config "$dir"
        echo ""
    fi

    if command -v popeye &> /dev/null && kubectl config current-context &> /dev/null; then
        echo "👁️  Running popeye cluster scan..."
        popeye
    fi
}

# Check all security tools are installed
check-security-tools() {
    echo "Security Tools Installation Status:"
    echo ""

    local tools=(
        "trivy:Security scanner for containers and IaC"
        "tfsec:Terraform security scanner"
        "tflint:Terraform linter"
        "dive:Docker image layer analyzer"
        "yq:YAML processor"
        "popeye:Kubernetes cluster sanitizer"
        "kube-capacity:Kubernetes resource analyzer"
        "aws-vault:AWS credential manager"
        "kubectl-krew:kubectl plugin manager"
        "steampipe:SQL interface for cloud APIs"
    )

    for tool_info in "${tools[@]}"; do
        IFS=':' read -r tool desc <<< "$tool_info"
        if command -v "$tool" &> /dev/null; then
            echo "✅ $tool - $desc"
        else
            echo "❌ $tool - $desc (not installed)"
        fi
    done
}

# Run Steampipe query from file
sp-run() {
    local query_file=$1

    if [[ -z "$query_file" ]]; then
        echo "Usage: sp-run <query-file.sql>"
        echo ""
        echo "Available query files:"
        echo "  ~/.steampipe/config/queries/aws-security.sql"
        echo "  ~/.steampipe/config/queries/kubernetes-security.sql"
        echo "  ~/.steampipe/config/queries/cost-optimization.sql"
        echo "  ~/.steampipe/config/queries/inventory.sql"
        return 1
    fi

    if [[ ! -f "$query_file" ]]; then
        # Try in config directory
        query_file="$HOME/.steampipe/config/queries/$query_file"
    fi

    if [[ ! -f "$query_file" ]]; then
        echo "Query file not found: $query_file"
        return 1
    fi

    steampipe query "$query_file"
}

# Run named queries from library
sp-aws-security() {
    sp-run "$HOME/.steampipe/config/queries/aws-security.sql"
}

sp-k8s-security() {
    sp-run "$HOME/.steampipe/config/queries/kubernetes-security.sql"
}

sp-cost-opt() {
    sp-run "$HOME/.steampipe/config/queries/cost-optimization.sql"
}

sp-inventory() {
    sp-run "$HOME/.steampipe/config/queries/inventory.sql"
}

# Interactive query shell
sp-shell() {
    echo "🔍 Starting Steampipe interactive shell..."
    echo "💡 Tip: Type .help for commands, .exit to quit"
    echo ""
    steampipe query
}

# Install all recommended plugins
sp-setup() {
    echo "📦 Installing Steampipe plugins..."
    echo ""

    # Start service if not running
    if ! steampipe service status &> /dev/null; then
        echo "Starting Steampipe service..."
        steampipe service start
    fi

    # Install plugins from config files
    echo "Installing plugins from configuration..."
    steampipe plugin install

    echo ""
    echo "✅ Steampipe setup complete!"
    echo ""
    echo "Available plugins:"
    steampipe plugin list
}

# Full security audit for current project
security-audit() {
    echo "🔒 Running full security audit..."
    echo ""

    # Detect project type
    if [[ -f "Dockerfile" ]]; then
        echo "📦 Docker project detected"
        if docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "$(basename $(pwd))"; then
            local image=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep "$(basename $(pwd))" | head -1)
            scan-image "$image"
        fi
    fi

    if [[ -d "terraform" ]] || [[ -f "*.tf" ]]; then
        echo "🏗️  Terraform detected"
        scan-terraform
    fi

    if [[ -d "k8s" ]] || [[ -d "kubernetes" ]]; then
        echo "☸️  Kubernetes manifests detected"
        scan-k8s
    fi

    if [[ -d ".git" ]]; then
        echo "🔍 Scanning for secrets in repository..."
        if command -v trivy &> /dev/null; then
            trivy fs --scanners secret .
        fi
    fi
}

# Compare K8s resource requests vs usage
k8s-cost-analysis() {
    local namespace=${1:-default}

    echo "💰 Kubernetes Cost Analysis"
    echo "Namespace: $namespace"
    echo ""

    if ! command -v kube-capacity &> /dev/null; then
        echo "❌ kube-capacity not installed"
        return 1
    fi

    echo "📊 Resource Capacity and Utilization:"
    kube-capacity --util -n "$namespace"
    echo ""

    echo "💡 Cost Optimization Tips:"
    echo "  - Look for pods with low utilization (<30%)"
    echo "  - Check for pods without resource limits"
    echo "  - Consider vertical pod autoscaling for variable workloads"
    echo "  - Run 'popeye' for additional recommendations"
}

# Parse YAML with yq helper
yaml-get() {
    local query=$1
    local file=$2

    if [[ -z "$query" ]] || [[ -z "$file" ]]; then
        echo "Usage: yaml-get '<yq query>' <file.yaml>"
        echo "Example: yaml-get '.spec.replicas' deployment.yaml"
        return 1
    fi

    yq eval "$query" "$file"
}

# Update YAML field
yaml-set() {
    local query=$1
    local file=$2

    if [[ -z "$query" ]] || [[ -z "$file" ]]; then
        echo "Usage: yaml-set '<yq query>' <file.yaml>"
        echo "Example: yaml-set '.spec.replicas = 5' deployment.yaml"
        return 1
    fi

    yq eval -i "$query" "$file"
    echo "✅ Updated $file"
}

# Extract K8s secret value
k8s-secret() {
    local secret_name=$1
    local key=$2
    local namespace=${3:-default}

    if [[ -z "$secret_name" ]] || [[ -z "$key" ]]; then
        echo "Usage: k8s-secret <secret-name> <key> [namespace]"
        echo "Example: k8s-secret db-credentials password production"
        return 1
    fi

    kubectl get secret "$secret_name" -n "$namespace" -o yaml | \
        yq eval ".data.\"$key\"" - | \
        base64 -d
    echo ""
}

# ╔══════════════════════════════════════════════════════════════╗
# ║ Quick Reference                                              ║
# ╚══════════════════════════════════════════════════════════════╝
#
# Security Scanning Workflow:
#
# 1. Docker Images:
#    trscan myapp:latest              # Scan for vulnerabilities
#    dive myapp:latest                # Analyze layers
#    scan-image myapp:latest          # Run both
#
# 2. Terraform:
#    tfl && tfsec                     # Lint + security scan
#    scan-terraform ./terraform       # Full scan
#
# 3. Kubernetes:
#    trk8s ./k8s                      # Scan manifests
#    kpop                             # Scan cluster
#    kcap-util                        # Resource analysis
#    scan-k8s                         # Full scan
#
# 4. Full Project Audit:
#    security-audit                   # Scan everything
#    check-security-tools             # Verify tools installed
#
# 5. AWS Credentials:
#    av add production                # Add credentials securely
#    av exec production -- aws s3 ls  # Use credentials
#    av login production              # Browser login
#
# 6. YAML Processing:
#    yaml-get '.spec.replicas' deploy.yaml     # Read value
#    yaml-set '.spec.replicas = 3' deploy.yaml # Update value
#    k8s-secret db-creds password              # Extract secret
