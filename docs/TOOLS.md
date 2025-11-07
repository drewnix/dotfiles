# Tools Reference

Quick reference for all tools in this dotfiles repository with installation status, documentation links, use cases, and common commands.

**Legend:**
- ✅ **Installed** - Tool is installed by bootstrap.sh
- 📦 **Via mise** - Tool is managed by mise version manager
- 🔄 **Planned** - Tool will be added soon
- 📋 **Manual** - Requires manual installation

---

## Table of Contents

- [Kubernetes Tools](#kubernetes-tools)
- [Infrastructure as Code](#infrastructure-as-code)
- [Container Tools](#container-tools)
- [Security & Scanning](#security--scanning)
- [Cloud Provider CLIs](#cloud-provider-clis)
- [Version Management](#version-management)
- [Shell Enhancements](#shell-enhancements)
- [Modern CLI Tools](#modern-cli-tools)
- [Development Tools](#development-tools)
- [Observability & Monitoring](#observability--monitoring)

---

## Kubernetes Tools

### kubectl

**Status:** ✅ Installed + 📦 Via mise
**What:** Official Kubernetes CLI - interact with clusters
**When to use:** All Kubernetes operations
**Docs:** https://kubernetes.io/docs/reference/kubectl/

**Common commands:**
```bash
kubectl get pods                    # List pods
kubectl describe pod <name>         # Describe resource
kubectl logs -f <pod>              # Follow logs
kubectl exec -it <pod> -- sh       # Exec into pod
kubectl apply -f manifest.yaml     # Apply configuration
```

**Your aliases:** `k` (kubectl), `kgp` (get pods), `kd` (describe), `kexec` (exec), `klog` (logs helper)

**Completion:** Auto-completion enabled in env.zsh

---

### k9s

**Status:** ✅ Installed
**What:** Terminal UI for Kubernetes (like htop for clusters)
**When to use:** Interactive exploration, real-time monitoring, quick resource management
**Why better than kubectl:** Visual interface, real-time updates, keyboard shortcuts
**Docs:** https://k9scli.io/
**Config:** `~/.config/k9s/config.yaml`

**Key bindings:**
- `:` - Command mode (`:pod`, `:svc`, `:deploy`)
- `/` - Filter resources
- `d` - Describe selected resource
- `l` - View logs
- `e` - Edit resource
- `ctrl-d` - Delete resource
- `?` - Help menu

**Your aliases:** `k9` or `k9s`

**Your config includes:**
- Refresh rate: 2 seconds
- Theme: catppuccin-mocha
- Mouse support enabled
- Shell pod namespace: default

---

### helm

**Status:** ✅ Installed + 📦 Via mise
**What:** Kubernetes package manager
**When to use:** Installing applications, managing releases, templating manifests
**Docs:** https://helm.sh/docs/

**Common commands:**
```bash
helm repo add stable https://...   # Add repository
helm search repo nginx             # Search charts
helm install myapp stable/nginx    # Install chart
helm upgrade myapp stable/nginx    # Upgrade release
helm list                          # List releases
helm uninstall myapp               # Remove release
```

**Your aliases:** Basic helm commands (check kubernetes.zsh)

---

### kubectx / kubens

**Status:** ✅ Installed
**What:** Fast context and namespace switching
**When to use:** Switching between clusters or namespaces
**Alternative:** `kubectl config use-context` (slower, more typing)
**Docs:** https://github.com/ahmetb/kubectx

**Common commands:**
```bash
kubectx                     # List contexts
kubectx staging             # Switch to staging context
kubectx -                   # Switch to previous context
kubens                      # List namespaces
kubens production           # Switch to production namespace
```

**Your aliases:** `kctx` (kubectx), `kns` (kubens), `kx` (kubectx), `kn` (kubens)

---

### stern

**Status:** ✅ Installed
**What:** Multi-pod log tailing with color coding per pod
**When to use:** Viewing logs from multiple pods simultaneously
**Why better than kubectl logs:** Color per pod, regex matching, simpler syntax
**Alternative:** `kubectl logs -l app=name -f` (no colors, harder to read)
**Docs:** https://github.com/stern/stern

**Common commands:**
```bash
stern nginx                 # All pods matching "nginx"
stern -n prod api          # In specific namespace
stern --tail 100 app       # Last 100 lines
stern -c nginx web         # Only nginx container in web pods
stern . -n prod            # All pods in namespace
```

**Your aliases:** `ks` (stern), `ksf` (stern --tail 1)

**Tips:**
- Each pod gets a unique color
- Use regex patterns: `stern "^nginx-.*"`
- Combine with grep: `stern app | grep ERROR`

---

### krew

**Status:** ✅ Installed (NEW)
**What:** kubectl plugin manager - access to 200+ kubectl plugins
**When to use:** Installing kubectl plugins for extended functionality
**Why you need it:** Unlocks plugins like kubectl-tree, kubectl-neat, kubectl-view-secret
**Docs:** https://krew.sigs.k8s.io/

**Installation:**
```bash
# Installed by bootstrap.sh
# Adds ~/.krew/bin to PATH
```

**Common commands:**
```bash
kubectl krew search               # Search plugins
kubectl krew install tree         # Install tree plugin
kubectl krew list                 # List installed
kubectl krew upgrade              # Update plugins
```

**Recommended plugins to install:**
```bash
kubectl krew install tree         # Show resource hierarchy
kubectl krew install neat         # Clean up kubectl output
kubectl krew install view-secret  # Decode secrets easily
kubectl krew install ns           # Quick namespace switching
kubectl krew install ctx          # Quick context switching
```

---

### kubetail

**Status:** ✅ Installed (NEW)
**What:** Tail Kubernetes logs from multiple pods simultaneously
**When to use:** Better multi-pod logging than stern for some use cases
**Alternative to:** stern (different approach, both useful)
**Docs:** https://github.com/johanhaleby/kubetail

**Common commands:**
```bash
kubetail app-name                     # Tail all pods matching "app-name"
kubetail app-name -n namespace        # In specific namespace
kubetail app-name -c container-name   # Specific container
kubetail -l app=nginx                 # By label selector
```

**Alias suggestion:** `kt` (add to kubernetes.zsh)

**Difference from stern:**
- kubetail: Bash script, simpler, colored output
- stern: Go binary, faster, more features

---

### popeye

**Status:** ✅ Installed (NEW)
**What:** Kubernetes cluster sanitizer - scans for issues and best practices
**When to use:** Regular cluster health checks, finding misconfigurations
**Why you need it:** Finds resource issues, security problems, best practice violations
**Docs:** https://popeyecli.io/

**Common commands:**
```bash
popeye                              # Scan current cluster
popeye --save                       # Save report to file
popeye -n production                # Scan specific namespace
popeye --output json > report.json  # JSON output
```

**What it checks:**
- Over-allocated resources
- Dead or unused resources
- Security issues (privileged pods, etc.)
- Best practices violations
- Port mismatches
- Container probes

**Integration with k9s:** Can run `:popeye` inside k9s

---

### kube-capacity

**Status:** ✅ Installed (NEW)
**What:** CLI tool for resource capacity and utilization analysis
**When to use:** Right-sizing pods, cost optimization, finding over-provisioned resources
**Why you need it:** Shows requests vs limits vs actual usage - essential for optimization
**Docs:** https://github.com/robscott/kube-capacity

**Common commands:**
```bash
kube-capacity                       # Show capacity across cluster
kube-capacity --util                # Include actual usage (requires metrics-server)
kube-capacity -n production         # Specific namespace
kube-capacity --pod-count           # Include pod counts
kube-capacity -o json               # JSON output
```

**Example output:**
```
NODE          CPU REQUESTS  CPU LIMITS  MEMORY REQUESTS  MEMORY LIMITS
node-1        60%           80%         70%              85%
  nginx-abc   10%           20%         15%              25%
  api-xyz     50%           60%         55%              60%
```

**Use for:**
- Finding over-provisioned pods (high requests, low usage)
- Identifying pods without limits
- Cost optimization opportunities

---

## Infrastructure as Code

### terraform

**Status:** ✅ Installed + 📦 Via mise
**What:** Infrastructure as Code tool for provisioning cloud resources
**When to use:** Creating, updating, destroying cloud infrastructure
**Docs:** https://terraform.io/docs

**Common commands:**
```bash
terraform init                      # Initialize working directory
terraform plan                      # Preview changes
terraform apply                     # Apply changes
terraform destroy                   # Destroy infrastructure
terraform workspace select prod    # Switch workspace
```

**Your aliases:** `tf`, `tfi` (init), `tfp` (plan), `tfa` (apply), `tfaa` (apply -auto-approve), `tfws` (workspace select)

**Full alias list:** See terraform.zsh for 30+ aliases

---

### tflint

**Status:** ✅ Installed (NEW)
**What:** Terraform linter - catches errors before plan/apply
**When to use:** Before committing IaC changes, in pre-commit hooks
**Why you need it:** Catches typos, misconfigurations, invalid values before expensive operations
**Alternative:** `terraform validate` (less comprehensive)
**Docs:** https://github.com/terraform-linters/tflint

**Common commands:**
```bash
tflint                              # Lint current directory
tflint --init                       # Initialize plugins
tflint --enable-rule=rule_name      # Enable specific rule
tflint --recursive                  # Lint all subdirectories
```

**Setup:**
```bash
# Create .tflint.hcl in your project
cat > .tflint.hcl << 'EOF'
plugin "aws" {
  enabled = true
  version = "0.21.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}
EOF

tflint --init
```

**What it catches:**
- Invalid resource names
- Deprecated syntax
- Provider-specific issues
- Typos in resource types

**Integration:** Add to pre-commit hooks or CI/CD

---

### tfsec

**Status:** ✅ Installed (NEW)
**What:** Terraform security scanner - static analysis for security issues
**When to use:** Before applying changes, in CI/CD pipelines
**Why you need it:** Prevents security misconfigurations (open security groups, unencrypted storage, etc.)
**Docs:** https://aquasecurity.github.io/tfsec/

**Common commands:**
```bash
tfsec                               # Scan current directory
tfsec --soft-fail                   # Don't exit with error code
tfsec --format json > report.json   # JSON output
tfsec --exclude-downloaded-modules  # Skip vendor modules
tfsec --severity HIGH,CRITICAL      # Only serious issues
```

**What it checks:**
- Open security groups (0.0.0.0/0)
- Unencrypted storage (S3, EBS, RDS)
- Public resources that should be private
- Missing encryption in transit
- Overly permissive IAM policies

**Example findings:**
```
aws-s3-enable-bucket-encryption
────────────────────────────────
  S3 Bucket does not have encryption enabled

  See https://tfsec.dev/docs/aws/s3/enable-bucket-encryption/
```

**Integration:** Run before `terraform apply`

---

### terragrunt

**Status:** ✅ Installed
**What:** Terraform wrapper for DRY configurations
**When to use:** Managing multiple environments, keeping Terraform DRY
**Docs:** https://terragrunt.gruntwork.io/

**Your aliases:** `tg`, `tgi` (init), `tgp` (plan), `tga` (apply), `tgra` (run-all)

---

## Container Tools

### docker

**Status:** ✅ Installed
**What:** Container platform for building and running containers
**When to use:** Building images, running containers, local development
**Docs:** https://docs.docker.com/

**Common commands:**
```bash
docker build -t myapp:v1.0 .       # Build image
docker run -d -p 8080:80 nginx     # Run container
docker ps                           # List running containers
docker logs -f container-name       # Follow logs
docker exec -it container sh        # Exec into container
```

**Your aliases:** `dps` (ps), `dex` (exec helper), `dlog` (logs helper), `dstopall`, `dclean`

**Full alias list:** See docker.zsh for 60+ aliases

---

### dive

**Status:** ✅ Installed (NEW)
**What:** Docker image layer analyzer - explore image contents
**When to use:** Optimizing image size, finding bloat, understanding layers
**Why you need it:** Shows wasted space, layer contents, efficiency score
**Docs:** https://github.com/wagoodman/dive

**Common commands:**
```bash
dive nginx:latest                   # Analyze image
dive myapp:v1.0                     # Analyze local image
CI=true dive myapp:v1.0             # CI mode (exit with error if inefficient)
```

**Interface:**
- **Tab** - Switch between layers and file tree
- **Ctrl+U** - Show only modified files
- **Ctrl+A** - Show added/modified/removed files
- **Ctrl+F** - Filter files

**What to look for:**
- **Efficiency score** - Aim for >90%
- **Wasted space** - Files duplicated across layers
- **Large files** - Unnecessary packages or artifacts

**Tips:**
- Use multi-stage builds to reduce final image size
- Combine RUN commands to reduce layers
- Clean up package manager caches in same RUN command

---

### docker-compose

**Status:** ✅ Installed
**What:** Tool for defining and running multi-container applications
**When to use:** Local development with multiple services
**Docs:** https://docs.docker.com/compose/

**Your aliases:** `dcu` (up), `dcud` (up -d), `dcd` (down), `dclogsvc` (service logs)

---

## Security & Scanning

### trivy

**Status:** ✅ Installed (NEW)
**What:** Security scanner for containers, IaC, filesystems, and more
**When to use:** Before pushing images, in CI/CD, scanning Kubernetes manifests, Terraform
**Why you need it:** Fast, accurate, comprehensive (images + IaC + filesystems)
**Alternative:** Clair (slower), Grype (less accurate), Snyk (commercial)
**Docs:** https://aquasecurity.github.io/trivy/

**Common commands:**
```bash
# Container images
trivy image nginx:latest                    # Scan image
trivy image --severity HIGH,CRITICAL app    # Only serious vulns
trivy image -f json nginx > report.json     # JSON output

# Infrastructure as Code
trivy config ./terraform/                   # Scan Terraform
trivy config ./k8s/                         # Scan Kubernetes manifests

# Filesystems
trivy fs .                                  # Scan current directory
trivy fs --scanners vuln,secret,misconfig . # Specific scanners

# Git repositories
trivy repo https://github.com/user/repo     # Scan remote repo
```

**What it scans:**
- Container images (OS packages + application dependencies)
- Kubernetes manifests
- Terraform/CloudFormation/Dockerfile
- Filesystem vulnerabilities
- Secrets in code
- Misconfigurations

**Integration:**
- Run in CI before deploying
- Use `.trivyignore` to suppress false positives
- Set up as pre-commit hook

**Example .trivyignore:**
```
# Ignore specific CVE
CVE-2021-12345

# Ignore CVE in specific package
CVE-2021-67890 pkg:golang/github.com/example/lib
```

---

### tfsec

**Status:** ✅ Installed (see Infrastructure as Code section above)

---

## Cloud Provider CLIs

### AWS CLI

**Status:** ✅ Installed + 📦 Via mise
**What:** Official AWS command line interface
**When to use:** All AWS operations
**Docs:** https://docs.aws.amazon.com/cli/

**Common commands:**
```bash
aws sts get-caller-identity        # Who am I?
aws ec2 describe-instances         # List EC2 instances
aws s3 ls                          # List S3 buckets
aws eks update-kubeconfig          # Update kubeconfig for EKS
```

**Your aliases:** `ec2-ls`, `s3-ls`, `eks-use`, `aws-whoami`, `awsp` (profile switch)

**Full alias list:** See aws.zsh for 47+ aliases

**Helper functions:**
- `aws-whoami` - Shows account, region, profile
- `awsp-select` - FZF profile switcher
- `ec2-ssh <name>` - SSH by instance name
- `eks-use <cluster>` - Update kubeconfig

---

### aws-vault

**Status:** ✅ Installed (NEW)
**What:** Secure AWS credential manager - stores credentials in OS keychain
**When to use:** Instead of plaintext ~/.aws/credentials file
**Why better:** Encrypted storage, MFA support, temporary session management
**Alternative:** Plain AWS credentials file (insecure, no MFA)
**Docs:** https://github.com/99designs/aws-vault

**Setup:**
```bash
# Add credentials (stored in OS keychain, not plaintext)
aws-vault add my-profile

# Execute commands with temporary credentials
aws-vault exec my-profile -- aws s3 ls

# Start shell with credentials
aws-vault exec my-profile -- bash

# Use with MFA
aws-vault exec my-profile --mfa-token=123456 -- aws s3 ls

# Rotate credentials
aws-vault rotate my-profile
```

**Integration with your aliases:**
```bash
# Instead of: awsp production && aws s3 ls
# Use: aws-vault exec production -- aws s3 ls

# Or start a shell:
aws-vault exec production -- zsh
# Now all AWS commands use production credentials
```

**Security benefits:**
- Credentials stored in OS keychain (macOS Keychain, Linux secret-service)
- Never written to ~/.aws/credentials in plaintext
- MFA support built-in
- Temporary session tokens (expire after 1 hour by default)
- Per-profile MFA configuration

---

### gcloud

**Status:** ✅ Installed
**What:** Google Cloud SDK CLI
**When to use:** All GCP operations
**Docs:** https://cloud.google.com/sdk/docs

**Common commands:**
```bash
gcloud config list                  # Show configuration
gcloud projects list                # List projects
gcloud compute instances list       # List GCE instances
gcloud container clusters list      # List GKE clusters
```

**Your aliases:** `gce-ls`, `gke-ls`, `gke-use`, `gcp-whoami`, `gproj-select`

**Full alias list:** See gcp.zsh for 71+ aliases

**Helper functions:**
- `gcp-whoami` - Shows account, project, region
- `gproj-select` - FZF project switcher
- `gce-ssh-name <name>` - SSH by instance name
- `gke-use <cluster>` - Get GKE credentials

---

## Version Management

### mise

**Status:** ✅ Installed
**What:** Fast polyglot version manager (asdf replacement, 10-100x faster)
**When to use:** Managing tool versions (Node.js, Python, Terraform, kubectl, etc.)
**Why better than asdf:** Written in Rust, much faster, built-in tools
**Docs:** https://mise.jdx.dev/

**Common commands:**
```bash
mise use --global nodejs@20         # Install globally
mise use nodejs@20                  # Install for current directory
mise ls                             # List installed versions
mise ls-remote nodejs               # Available versions
mise current                        # Show active versions
mise upgrade                        # Update all tools
```

**Managed in this repo:**
- nodejs 20.11.0
- python 3.12.1
- golang 1.21.6
- rust 1.75.0
- terraform latest
- kubectl 1.29.0
- helm 3.14.0
- awscli 2.15.0

**Config:** `~/.config/mise/config.toml` and `.tool-versions`

**Features enabled:**
- Auto-install missing tools
- Legacy version file support (.node-version, .python-version, etc.)
- 4 parallel jobs for faster installation

---

### direnv

**Status:** 📦 Via mise
**What:** Load and unload environment variables based on directory
**When to use:** Per-project environment variables
**Docs:** https://direnv.net/

**Setup:**
```bash
# Create .envrc in project
echo 'export DATABASE_URL=postgres://localhost/mydb' > .envrc

# Allow direnv to load it
direnv allow

# Now DATABASE_URL is set when you cd into the directory
```

---

## Shell Enhancements

### starship

**Status:** ✅ Installed
**What:** Fast, customizable shell prompt written in Rust
**When to use:** Better prompt than default bash/zsh
**Why better:** Shows context (K8s, AWS, GCP, git), fast, highly customizable
**Docs:** https://starship.rs/

**Config:** `~/.config/starship.toml`

**What it shows:**
- Current directory with Git status
- Kubernetes context and namespace
- Terraform workspace
- AWS profile and region
- GCP project
- Docker context
- Programming language versions (from mise)
- Command duration
- Current time

**Customization:**
```bash
# Edit config
vim ~/.config/starship.toml

# Prompt updates automatically
```

---

### zsh-autosuggestions

**Status:** ✅ Installed
**What:** Command history suggestions as you type
**When to use:** Automatically enabled
**Docs:** https://github.com/zsh-users/zsh-autosuggestions

**Usage:**
- Suggestions appear in gray as you type
- Press `→` to accept
- Press `→` partially to accept word-by-word

---

### zsh-syntax-highlighting

**Status:** ✅ Installed
**What:** Real-time syntax highlighting for commands
**When to use:** Automatically enabled
**Docs:** https://github.com/zsh-users/zsh-syntax-highlighting

**Colors:**
- Green: Valid command
- Red: Invalid command
- Blue: Directory
- Cyan: File

---

## Modern CLI Tools

### fzf

**Status:** ✅ Installed
**What:** Fuzzy finder for files, command history, anything
**When to use:** Searching files, history, contexts, profiles
**Docs:** https://github.com/junegunn/fzf

**Built-in shortcuts:**
- `Ctrl-R` - Search command history
- `Ctrl-T` - Search files
- `Alt-C` - Search directories (cd into)

**Your custom integrations:**
- `awsp-select` - AWS profile switcher
- `gproj-select` - GCP project switcher
- `kctx-fzf` - Kubernetes context switcher

**Use in commands:**
```bash
vim $(fzf)                          # Open file with fzf
cd $(fd --type d | fzf)            # cd to directory
docker exec -it $(docker ps | fzf) sh  # Exec into container
```

---

### ripgrep (rg)

**Status:** ✅ Installed
**What:** Fast grep alternative with smart defaults
**When to use:** Searching in files (much faster than grep)
**Alternative:** `grep` (slower, less features)
**Docs:** https://github.com/BurntSushi/ripgrep

**Common commands:**
```bash
rg "TODO"                           # Search in current directory
rg "error" -t log                   # Only .log files
rg "function" -g "*.js"            # Only .js files
rg -i "error"                       # Case-insensitive
rg --files-with-matches "TODO"     # Only show filenames
```

**Your aliases:** `qgrep` uses grep, consider switching to rg

---

### fd

**Status:** ✅ Installed
**What:** Fast find alternative with smart defaults
**When to use:** Finding files (much faster than find)
**Alternative:** `find` (slower, more verbose)
**Docs:** https://github.com/sharkdp/fd

**Common commands:**
```bash
fd config                           # Find files/dirs matching "config"
fd -e js                            # Find all .js files
fd -t f -t d config                # Only files and directories
fd -H .git                          # Include hidden files
fd -E node_modules                  # Exclude pattern
```

**Your aliases:** `ff` (find files), `fd` (find dirs) - consider using fd directly

---

### bat

**Status:** ✅ Installed
**What:** cat with syntax highlighting and git integration
**When to use:** Viewing file contents
**Alternative:** `cat` (no colors, no line numbers)
**Docs:** https://github.com/sharkdp/bat

**Common commands:**
```bash
bat file.js                         # View with syntax highlighting
bat -n file.py                      # Show line numbers
bat -A file.txt                     # Show all characters (tabs, spaces)
bat --paging=never file.log         # Don't use pager
```

**Integration:**
```bash
# Use as man pager
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
```

---

### eza

**Status:** ✅ Installed
**What:** Modern ls replacement with icons, git integration, colors
**When to use:** Listing files (better than ls)
**Alternative:** `ls` (no colors, no icons, no git status)
**Docs:** https://github.com/eza-community/eza

**Common commands:**
```bash
eza                                 # Better ls
eza -l                              # Long format
eza -la                             # Include hidden
eza --tree                          # Tree view
eza --git                           # Show git status
```

**Your aliases:** `ls`, `ll`, `la`, `lt` all use eza

---

### yazi

**Status:** ✅ Installed
**What:** Terminal file manager with preview support
**When to use:** Navigating directories visually, previewing files
**Alternative:** `ranger` (slower, less features)
**Docs:** https://yazi-rs.github.io/

**Your aliases:** `y` (yazi), plus 20+ aliases in yazi.zsh

**Config:** `~/.config/yazi/`

---

### zoxide

**Status:** ✅ Installed
**What:** Smart directory jumper (z replacement)
**When to use:** Quickly jumping to frequently used directories
**Alternative:** `cd` (requires full paths)
**Docs:** https://github.com/ajeetdsouza/zoxide

**Common commands:**
```bash
z dotfiles                          # Jump to ~/dotfiles
z doc                               # Jump to ~/Documents
zi                                  # Interactive selection with fzf
```

**How it works:**
- Tracks directory usage
- Smart matching: `z dot` finds `~/dotfiles`
- Learns your patterns over time

---

## Development Tools

### jq

**Status:** ✅ Installed
**What:** JSON processor - parse, filter, transform JSON
**When to use:** Working with JSON from APIs, kubectl, AWS CLI
**Docs:** https://stedolan.github.io/jq/

**Common commands:**
```bash
cat file.json | jq .                # Pretty-print
kubectl get pod -o json | jq .spec  # Extract field
jq '.items[].name' file.json        # Array iteration
jq -r '.key'                        # Raw output (no quotes)
```

**Your usage:**
- `dinspectj` - Docker inspect with jq

---

### yq

**Status:** ✅ Installed (NEW)
**What:** YAML processor (like jq but for YAML)
**When to use:** Parsing Kubernetes manifests, Helm values, any YAML files
**Why you need it:** You have jq for JSON, need yq for YAML
**Docs:** https://github.com/mikefarah/yq

**Common commands:**
```bash
# Read values
yq eval '.spec.replicas' deployment.yaml           # Extract field
yq eval '.metadata.labels' pod.yaml                # Get labels

# Update values
yq eval '.spec.replicas = 3' -i deployment.yaml    # Update in-place
yq eval '.image.tag = "v2.0"' values.yaml          # Update nested field

# Merge files
yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' base.yaml override.yaml

# Convert formats
yq eval -o=json deployment.yaml | jq .             # YAML to JSON
kubectl get pod -o yaml | yq eval '.spec'          # Parse kubectl output

# Multiple documents
yq eval 'select(.kind == "Deployment")' all.yaml   # Filter by field
```

**Use cases:**
- Extract values from Kubernetes manifests
- Update Helm values files
- Parse kubectl output
- Validate YAML syntax
- Merge configuration files

**Integration with kubectl:**
```bash
# Get specific fields from K8s resources
kubectl get deploy -o yaml | yq eval '.items[].metadata.name'

# Update manifests before applying
yq eval '.spec.replicas = 5' -i deployment.yaml
kubectl apply -f deployment.yaml
```

---

### git

**Status:** ✅ Installed
**What:** Version control system
**When to use:** Always
**Docs:** https://git-scm.com/docs

**Your aliases:** See git.zsh for 82+ aliases

**Helper functions:**
- `ginfo` - Repository information
- `gsync` - Sync with main branch
- `gclean-merged` - Delete merged branches

---

## Observability & Monitoring

### kubetail

**Status:** ✅ Installed (see Kubernetes Tools section above)

---

### popeye

**Status:** ✅ Installed (see Kubernetes Tools section above)

---

### kube-capacity

**Status:** ✅ Installed (see Kubernetes Tools section above)

---

### stern

**Status:** ✅ Installed (see Kubernetes Tools section above)

---

## Quick Reference by Use Case

### "I want to..."

**...scan my Docker image for vulnerabilities**
→ `trivy image myapp:latest`

**...check if my Terraform is secure**
→ `tfsec .` and `tflint .`

**...see what's in my Docker image layers**
→ `dive myapp:latest`

**...tail logs from multiple pods**
→ `stern app-name` or `kubetail app-name`

**...check if my Kubernetes resources are over-provisioned**
→ `kube-capacity --util`

**...find issues in my Kubernetes cluster**
→ `popeye`

**...parse YAML files**
→ `yq eval '.field' file.yaml`

**...securely manage AWS credentials**
→ `aws-vault add profile` then `aws-vault exec profile -- aws s3 ls`

**...install kubectl plugins**
→ `kubectl krew search` then `kubectl krew install plugin-name`

**...switch between tool versions**
→ `mise use nodejs@20` or add to `.tool-versions`

---

## Installation Status Summary

### ✅ Currently Installed (60+ tools)

**Kubernetes:** kubectl, k9s, helm, kubectx, kubens, stern
**IaC:** terraform, terragrunt
**Cloud:** aws-cli, gcloud
**Containers:** docker, docker-compose
**Shell:** starship, zsh-autosuggestions, zsh-syntax-highlighting
**CLI Tools:** fzf, ripgrep, fd, bat, eza, yazi, zoxide, jq
**Development:** git, vim, tmux, mise

### ✅ Newly Added (Top 10 Recommendations)

**Kubernetes:** krew, kubetail, popeye, kube-capacity
**Security:** trivy, tfsec, tflint
**Containers:** dive
**Cloud:** aws-vault
**Development:** yq

---

## Adding New Tools

When adding a tool to this repository:

1. **Add to bootstrap.sh** - In appropriate package array
2. **Test installation** - Run `./bootstrap.sh` on clean system
3. **Add aliases** - Create or update alias file in `zsh/.config/zsh/aliases/`
4. **Document here** - Add section to TOOLS.md with status, docs, examples
5. **Update USER_GUIDE.md** - Add workflow examples
6. **Update README.md** - Add to features list if significant
7. **Update CLAUDE.md** - Add architectural notes if needed

---

## Contributing

Found a useful tool? Add it following the format above:

**Required sections:**
- Status (Installed/Planned/Manual)
- What (1-2 sentence description)
- When to use
- Docs link
- Common commands
- Your aliases (if applicable)

**Optional sections:**
- Why better than X
- Alternative
- Tips
- Configuration
- Integration notes

---

**Last updated:** 2024-11-05
**Total tools documented:** 70+
