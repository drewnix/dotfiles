# Dotfiles User Guide

**Complete guide to mastering your cloud-native DevOps workflow**

Welcome! This guide will help you learn and master all the tools, aliases, and workflows in this dotfiles setup. Whether you're new to these tools or an experienced user, you'll find practical examples and tips to boost your productivity.

---

## Table of Contents

1. [Getting Started](#getting-started)
2. [Shell Basics](#shell-basics)
3. [Kubernetes Workflows](#kubernetes-workflows)
4. [Terraform Workflows](#terraform-workflows)
5. [AWS CLI Workflows](#aws-cli-workflows)
6. [GCP Workflows](#gcp-workflows)
7. [Docker & Containers](#docker--containers)
8. [Git Workflows](#git-workflows)
9. [General Utilities](#general-utilities)
10. [Version Management with mise](#version-management-with-mise)
11. [Starship Prompt](#starship-prompt)
12. [Tmux Terminal Multiplexer](#tmux-terminal-multiplexer)
13. [Claude Code Integration](#claude-code-integration)
14. [Productivity Tips](#productivity-tips)
15. [Real-World Workflows](#real-world-workflows)
16. [Troubleshooting](#troubleshooting)

---

## Getting Started

### First-Time Setup

After installing the dotfiles, restart your terminal or run:

```bash
# Reload your shell
exec zsh

# Or source the config
source ~/.zshrc
```

### Exploring Available Aliases

```bash
# List all aliases
alias

# Search for specific aliases
alias | grep kubectl

# Find aliases for a tool
alias | grep terraform
```

### Getting Help

Most helper functions have built-in help:

```bash
# Run function without arguments to see usage
klog          # Shows: Usage: klog <pod-name-pattern> [namespace]
aws-whoami    # Shows your AWS identity
gcp-whoami    # Shows your GCP config
```

---

## Shell Basics

### Understanding the Modular Structure

Your `.zshrc` loads modules from `~/.config/zsh/aliases/`:

```
~/.config/zsh/
├── env.zsh              # Environment variables, PATH, completions
└── aliases/
    ├── general.zsh      # General shell utilities
    ├── git.zsh          # Git workflows
    ├── kubernetes.zsh   # Kubernetes/kubectl
    ├── terraform.zsh    # Terraform
    ├── aws.zsh          # AWS CLI
    ├── gcp.zsh          # GCP/gcloud
    └── docker.zsh       # Docker & containers
```

### Customizing Your Setup

**Add personal aliases:**

```bash
# Create a local config file (not tracked by git)
vim ~/.zshrc.local

# Add your aliases
alias myserver='ssh user@myserver.com'
alias mydb='psql -h localhost -U postgres'
export MY_VAR="value"

# Save and reload
source ~/.zshrc
```

**Company-specific config:**

```bash
# Create company config
vim ~/.zshrc.spl

# Add work-specific stuff
export COMPANY_VPN="vpn.company.com"
alias work-vpn='sudo openconnect $COMPANY_VPN'
```

### Essential Shell Functions

**Navigation:**

```bash
# Go up multiple directories
up 3              # cd ../../..

# Make directory and cd into it
mkcd myproject    # mkdir -p myproject && cd myproject

# Quick directory bookmarks (edit to customize)
dev               # cd ~/dev
dl                # cd ~/Downloads
docs              # cd ~/Documents
```

**Finding Files:**

```bash
# Quick find by name
qfind config      # find . -iname "*config*"

# Quick grep in files
qgrep "TODO"      # grep -r "TODO" --include="*" .
qgrep "error" "*.log"  # Search only in .log files
```

**File Operations:**

```bash
# Extract any archive
extract file.tar.gz
extract archive.zip
extract package.tar.bz2

# Quick backup
backup important.conf    # Creates important.conf.backup-20240118-143022

# Show directory size
dirsize                  # Current directory
dirsize /var/log         # Specific directory

# Find largest files
largest 10               # Top 10 largest files in current dir
largest 20 /var/log      # Top 20 in /var/log
```

**System Info:**

```bash
# Show PATH in readable format
path

# System information
sysinfo              # CPU, memory, disk, uptime

# Disk space summary
diskspace            # Shows usage + largest directories

# Public IP address
publicip             # Shows both IPv4 and IPv6
myip                 # Quick IPv4 only
```

---

## Kubernetes Workflows

### Core kubectl Shortcuts

**Basic operations:**

```bash
# Instead of: kubectl get pods
kgp                    # Get pods in current namespace
kgp -A                 # Get all pods across all namespaces
kgpa                   # Alias for kgp -A

# Instead of: kubectl get deployments
kgd                    # Get deployments

# Instead of: kubectl get services
kgsvc                  # Get services with wide output

# Get all resources
kga                    # kubectl get all
kgaa                   # kubectl get all -A (all namespaces)
```

**Describe and edit:**

```bash
# Describe resources
kdp my-pod             # kubectl describe pod my-pod
kdd my-deployment      # kubectl describe deployment
kdsvc my-service       # kubectl describe service

# Edit resources
ked my-deployment      # kubectl edit deployment my-deployment
kesvc my-service       # kubectl edit service my-service
```

**Delete operations:**

```bash
# Delete resources
kdelp my-pod           # Delete pod
kdeld my-deployment    # Delete deployment
kdelsvc my-service     # Delete service

# Force delete a pod
kdel pod my-pod --grace-period=0 --force
```

### Context and Namespace Management

**Using kubectl config:**

```bash
# View current context
kcfgcurrent            # kubectl config current-context

# List all contexts
kcfggc                 # kubectl config get-contexts

# Switch context
kcfguc staging         # kubectl config use-context staging

# Switch namespace
kns production         # Sets namespace to 'production'
kns default            # Back to default namespace

# View current config
kinfo                  # Shows context, namespace, server
```

**Using kubectx/kubens (if installed):**

```bash
# Switch contexts faster
kx                     # List contexts (interactive)
kx staging             # Switch to staging
kxp                    # Switch to previous context

# Switch namespaces faster
kn                     # List namespaces (interactive)
kn production          # Switch to production
knp                    # Switch to previous namespace
```

### Logs and Debugging

**View logs:**

```bash
# Basic logs
kl my-pod              # kubectl logs my-pod
klf my-pod             # kubectl logs -f my-pod (follow)

# Helper function - find pod by partial name
klog nginx             # Finds pod matching "nginx" and tails logs
# Example output:
# Tailing logs for: nginx-deployment-7d9f8c6b4d-x9k2m
```

**Execute into pods:**

```bash
# Basic exec
kexec my-pod           # kubectl exec -it my-pod -- sh

# Helper function - find pod by partial name
kexe nginx             # Execs into pod matching "nginx"
kexe nginx production sh  # In specific namespace with specific shell
kexe postgres default bash  # Use bash instead of sh

# Example workflow:
kexe api              # Finds: api-deployment-abc123
# Now you're inside the container
$ ls
$ cat /etc/config/app.conf
$ exit
```

**Events and troubleshooting:**

```bash
# Get events sorted by time
kgev                   # kubectl get events --sort-by=.metadata.creationTimestamp

# Watch pods in real-time
kwp                    # watch -n 2 kubectl get pods

# Get resource usage
kresources             # kubectl top pods --containers

# Get all resources in a namespace
kgall production       # Gets all resources in 'production' namespace
```

### Advanced Kubernetes Helpers

**Stern - multi-pod log tailing (if installed):**

```bash
# Tail logs from multiple pods
ks api                 # stern api (all pods matching "api")
ksf api                # stern --tail 1 api (follow from recent)

# Tail all pods in namespace
ks . -n production     # All pods in production namespace

# Filter by container
ks api -c nginx        # Only nginx container
```

**k9s - terminal UI (if installed):**

```bash
# Launch k9s
k9                     # Full terminal UI for Kubernetes

# Navigate with:
# - :pod, :svc, :deploy (resource shortcuts)
# - / to filter
# - d to describe
# - l for logs
# - e to edit
# - ctrl-d to delete
```

### Real Kubernetes Workflow Example

```bash
# 1. Check current context
kinfo
# Current Context: production-cluster
# Current Namespace: default

# 2. Switch to staging namespace
kns staging

# 3. List running pods
kgp
# NAME                          READY   STATUS    RESTARTS   AGE
# api-7d9f8c6b4d-x9k2m         1/1     Running   0          2d
# worker-5f6g7h8i9j-a1b2c      1/1     Running   3          5d

# 4. Check logs for errors
klog api
# (tails logs from api-7d9f8c6b4d-x9k2m)
# Look for errors...

# 5. Exec into pod to debug
kexe api
$ ps aux
$ netstat -tlnp
$ cat /app/logs/error.log
$ exit

# 6. Check recent events
kgev | tail -20

# 7. Describe the deployment
kdd api

# 8. Edit if needed
ked api
# (opens in vim, make changes, save)

# 9. Watch rollout
kubectl rollout status deployment api

# 10. Back to default namespace
kns default
```

---

## Terraform Workflows

### Basic Terraform Commands

```bash
# Standard workflow
tfi                    # terraform init
tfp                    # terraform plan
tfa                    # terraform apply
tfaa                   # terraform apply -auto-approve

# Destroy
tfd                    # terraform destroy
tfda                   # terraform destroy -auto-approve (careful!)

# Validation and formatting
tfv                    # terraform validate
tff                    # terraform fmt (current dir)
tffr                   # terraform fmt -recursive

# Output and state
tfo                    # terraform output
tfs                    # terraform show
```

### Workspace Management

**Basic workspace operations:**

```bash
# List workspaces
tfwl                   # terraform workspace list

# Create new workspace
tfwn staging           # terraform workspace new staging

# Switch workspace
tfws production        # terraform workspace select production

# Show current workspace
tfwsh                  # terraform workspace show

# Delete workspace
tfwd old-env           # terraform workspace delete old-env
```

**Helper functions:**

```bash
# Switch workspace and plan
tfwsp staging          # Switches to 'staging' and runs plan

# Show workspace info
tfinfo
# Output:
# Workspace: staging
# State resources: 47
# (lists all resources)

# List all workspaces with resource counts
tfworkspaces
# Output:
# Terraform Workspaces:
# * staging (47 resources)
#   production (132 resources)
#   dev (23 resources)
```

### State Management

```bash
# List state resources
tfsl                   # terraform state list

# Show specific resource
tfss aws_instance.web  # terraform state show aws_instance.web

# Move resource in state
tfsmv                  # terraform state mv

# Remove from state (doesn't destroy)
tfsrm aws_instance.old # terraform state rm aws_instance.old

# Pull/push state
tfsp                   # terraform state pull
tfspu                  # terraform state push
```

### Advanced Terraform Helpers

**Plan with variable file:**

```bash
# Plan with specific tfvars
tfpvar staging.tfvars
# Runs: terraform plan -var-file="staging.tfvars"

# Apply with tfvars
tfavar production.tfvars
# Runs: terraform apply -var-file="production.tfvars"
```

**Cleanup operations:**

```bash
# Clean terraform cache and backups
tfclean
# Removes:
# - .terraform directories
# - *.tfstate.backup files
# - .terraform.lock.hcl files
```

**Validate all terraform in subdirectories:**

```bash
# Validate all .tf files in project
tfvalidate-all
# Finds all directories with .tf files and runs terraform validate
```

### Terragrunt Support (if installed)

```bash
# Basic commands
tg                     # terragrunt
tgi                    # terragrunt init
tgp                    # terragrunt plan
tga                    # terragrunt apply
tgaa                   # terragrunt apply -auto-approve

# Run-all commands (multiple modules)
tgra                   # terragrunt run-all
tgrap                  # terragrunt run-all plan
tgraa                  # terragrunt run-all apply
tgrad                  # terragrunt run-all destroy
```

### Real Terraform Workflow Example

```bash
# 1. Check current workspace
tfinfo
# Workspace: dev
# State resources: 15

# 2. Create new workspace for staging
tfwn staging

# 3. Initialize
tfi

# 4. Plan with staging variables
tfpvar staging.tfvars
# Review the plan output...

# 5. Apply changes
tfavar staging.tfvars
# Or auto-approve if confident:
# tfaa -var-file=staging.tfvars

# 6. Check outputs
tfo

# 7. List resources in state
tfsl

# 8. Show specific resource
tfss aws_eks_cluster.main

# 9. Switch to production workspace
tfws production

# 10. Compare workspaces
tfworkspaces
# * production (132 resources)
#   staging (47 resources)
#   dev (15 resources)
```

---

## AWS CLI Workflows

### Identity and Configuration

```bash
# Check who you are
aws-whoami
# Output:
# AWS Identity Information:
# UserId: AIDAI...
# Account: 123456789012
# Arn: arn:aws:iam::123456789012:user/andrew
#
# Current Region: us-west-2
# Current Profile: default

# List available profiles
awspl                  # aws configure list-profiles

# Switch profile
awsp myprofile         # export AWS_PROFILE=myprofile

# Interactive profile switcher (requires fzf)
awsp-select
# Shows fuzzy-searchable list of profiles
```

### EC2 Management

**List instances:**

```bash
# List all instances
ec2-ls
# Shows table: InstanceId, Type, State, PublicIP, PrivateIP, Name

# List only running instances
ec2-running
# Filtered view of running instances only
```

**Find instance by name:**

```bash
# Get instance ID by name tag
ec2-id web-server
# Output:
# i-0abc123def456  web-server-production

ec2-id api
# Finds any instance with "api" in name
```

**SSH to instances:**

```bash
# SSH by name (finds public IP automatically)
ec2-ssh web-server
# Finds instance named "web-server" and SSHs as ec2-user

ec2-ssh api ubuntu
# SSH as 'ubuntu' user instead of default 'ec2-user'

# SSM Session Manager (no SSH key needed)
ec2-ssm web-server
# Connects via AWS Systems Manager Session Manager
```

**Manage instance state:**

```bash
# Start instance
ec2-start i-0abc123

# Stop instance
ec2-stop i-0abc123

# Terminate instance (careful!)
ec2-terminate i-0abc123
```

### S3 Operations

```bash
# List buckets
s3-ls                  # aws s3 ls
s3-buckets             # List bucket names only (table format)

# List bucket contents
s3-ls s3://my-bucket/

# Copy files
s3-cp myfile.txt s3://my-bucket/
s3-cp s3://my-bucket/file.txt ./

# Sync directories
s3-sync ./dist s3://my-bucket/

# Create/remove bucket
s3-mb s3://new-bucket
s3-rb s3://old-bucket

# Empty bucket (with confirmation)
s3-empty my-bucket
# WARNING: This will delete all objects in s3://my-bucket
# Are you sure? (yes/no): yes
```

### EKS (Kubernetes on AWS)

```bash
# List EKS clusters
eks-clusters
# Output (table):
# my-cluster-dev
# my-cluster-prod

# Update kubeconfig for a cluster
eks-kubeconfig my-cluster-prod
# Runs: aws eks update-kubeconfig --name my-cluster-prod

# Helper - find and configure cluster by partial name
eks-use prod
# Finds cluster matching "prod" and updates kubeconfig
# Output:
# Updating kubeconfig for cluster: my-cluster-prod
# Updated context arn:aws:eks:...
```

### Lambda Functions

```bash
# List functions
lambda-ls
# Table: FunctionName, Runtime, LastModified

# Invoke function
lambda-invoke my-function
# Runs function synchronously

# View logs (requires function name)
lambda-logs my-function
# Tails CloudWatch logs for last 60 minutes

lambda-logs my-function 120
# Last 120 minutes
```

### IAM Operations

```bash
# List users
iam-users
# Table: UserName, CreateDate

# List roles
iam-roles
# Table: RoleName, CreateDate

# List policies
iam-policies
# Lists custom policies only

# Current identity
iam-whoami             # Alias for aws-whoami
```

### Systems Manager (Parameter Store)

```bash
# List parameters
ssm-params
# Table: Name, Type, LastModifiedDate

# Get parameter value
ssm-get /app/config/db-host
# Returns plaintext value

# Get with decryption (for SecureString)
ssm-gets /app/config/db-password
# Decrypts and returns value

# Get all parameters under a path
ssm-get-path /app/config
# Returns all parameters like:
# /app/config/db-host  = mysql.example.com
# /app/config/db-name  = myapp
```

### Real AWS Workflow Example

```bash
# 1. Check current AWS identity
aws-whoami
# Account: 123456789012, Region: us-west-2, Profile: production

# 2. Switch to dev profile
awsp dev
aws-whoami
# Account: 987654321098, Region: us-east-1, Profile: dev

# 3. List running EC2 instances
ec2-running

# 4. SSH into API server
ec2-ssh api
# Finds: api-server-dev (i-0abc123)
# Connecting to 54.123.45.67 as ec2-user

# Inside instance:
$ sudo systemctl status myapp
$ sudo tail -f /var/log/myapp/error.log
$ exit

# 5. Check S3 buckets
s3-buckets

# 6. Download config from S3
s3-cp s3://my-config-bucket/app.yaml ./

# 7. Update EKS kubeconfig
eks-use dev-cluster

# 8. Verify kubectl works
kgp

# 9. Get parameter from Parameter Store
ssm-gets /dev/app/api-key

# 10. Back to production profile
awsp production
```

---

## GCP Workflows

### Identity and Configuration

```bash
# Check current GCP configuration
gcp-whoami
# Output:
# GCP Configuration:
# Account: andrew@example.com
# Project: my-project-dev
# Region: us-central1
# Zone: us-central1-a
#
# Active Configuration:
# * dev    my-project-dev    andrew@example.com

# List all projects
gproj-ls
# Table of all accessible projects

# Switch project
gproj-set my-project-prod
# Sets active project to my-project-prod

# Interactive project switcher (requires fzf)
gproj-select
# Fuzzy search through all projects
```

### Configuration Profiles

```bash
# List configurations
gconf-ls
# Shows all gcloud configurations (like AWS profiles)

# Create new configuration
gconf-create staging
# Creates new config named 'staging'

# Switch configuration
gconf-activate staging
# Or use the helper:
gconf-switch staging

# Interactive switcher (requires fzf)
gconf-switch
# No argument = fuzzy search
```

### GCE (Compute Engine)

**List instances:**

```bash
# List all instances
gce-ls
# Table: NAME, ZONE, MACHINE_TYPE, INTERNAL_IP, EXTERNAL_IP, STATUS

# List zones
gce-zones
# All zones by region

gce-zones us-central1
# Zones only in us-central1
```

**SSH to instances:**

```bash
# SSH by name
gce-ssh my-instance
# Uses gcloud compute ssh

# SSH by name pattern (helper function)
gce-ssh-name web
# Finds instance matching "web" and SSHs to it

gce-ssh-name api us-central1-a
# Specify zone explicitly
```

**Manage instances:**

```bash
# Start instance
gce-start my-instance

# Stop instance
gce-stop my-instance

# Delete instance
gce-delete my-instance
```

### GKE (Kubernetes on GCP)

```bash
# List clusters
gke-ls
# Table: NAME, LOCATION, MASTER_VERSION, NUM_NODES, STATUS

# Get credentials
gke-get my-cluster
# Full command: gcloud container clusters get-credentials my-cluster

# Helper - find cluster by partial name
gke-use prod
# Finds cluster matching "prod" and gets credentials
# Output:
# Getting credentials for cluster: my-cluster-prod in us-central1
# Fetching cluster endpoint and auth data.
# kubeconfig entry generated

# List node pools
gke-nodepools --cluster my-cluster
```

### Cloud Storage (GCS)

```bash
# List buckets
gsls                   # gsutil ls

# Create bucket
gsmb gs://my-new-bucket

# Remove bucket
gsrb gs://old-bucket

# Copy files
gscp myfile.txt gs://my-bucket/
gscp gs://my-bucket/file.txt ./

# Sync directories
gssync ./dist gs://my-bucket/static/

# Move/rename
gsmv gs://bucket/old.txt gs://bucket/new.txt
```

### Cloud Run

```bash
# List services
gcr-ls
# Table: SERVICE, REGION, URL, LAST_DEPLOYED

# Deploy service
gcr-deploy my-service --image gcr.io/project/image:tag

# Delete service
gcr-delete my-service

# Tail logs
gcr-logs-tail my-service
# Tails Cloud Run logs for service

gcr-logs-tail my-service us-central1
# Specify region
```

### IAM and Service Accounts

```bash
# List service accounts
giam-accounts

# List IAM roles
giam-roles

# Get project IAM policy
giam-policy
# Shows all IAM bindings for current project
```

### Real GCP Workflow Example

```bash
# 1. Check current configuration
gcp-whoami
# Project: dev-project, Region: us-central1

# 2. Switch to production project
gcp-switch prod-project
# Switches project AND updates kubeconfig if GKE exists

# 3. List compute instances
gce-ls

# 4. SSH into API server
gce-ssh-name api
# Finds and connects to instance

# 5. List GKE clusters
gke-ls

# 6. Get cluster credentials
gke-use production-cluster

# 7. Verify kubectl works
kgp

# 8. List Cloud Storage buckets
gsls

# 9. Download config
gscp gs://my-config/app.yaml ./

# 10. List Cloud Run services
gcr-ls

# 11. Tail Cloud Run logs
gcr-logs-tail api-service
```

---

## Docker & Containers

### Basic Docker Commands

```bash
# List images
di                     # docker images

# List containers
dps                    # docker ps (running only)
dpsa                   # docker ps -a (all containers)

# Run container
drun nginx             # docker run nginx
dqrun ubuntu bash      # Quick run with -it --rm

# Stop/start/restart
dstop my-container
dstart my-container
drestart my-container

# Remove containers/images
drm my-container
drmi my-image
```

### Logs and Debugging

```bash
# View logs
dlogs my-container
dlogsf my-container    # Follow logs (tail -f)

# Helper - find container by partial name
dlog nginx
# Finds container matching "nginx" and shows logs

dlog nginx -f
# Follow logs for container matching "nginx"

# Exec into container
dexec my-container
# Runs: docker exec -it my-container sh

# Helper - find container by partial name
dex nginx
# Finds container matching "nginx" and execs into it

dex nginx bash
# Use bash instead of sh
```

### System Management

```bash
# System info
dinfo                  # docker info
dversion              # docker version
ddf                   # docker system df (disk usage)

# Cleanup
dprune                # docker system prune
dprunea               # docker system prune -a (includes images)
dprunev               # docker system prune --volumes

# Helper functions
dstopall              # Stop all running containers
drmall                # Remove all stopped containers
drmiall               # Remove all dangling images

dclean                # Complete cleanup (with confirmation)
# WARNING: This will remove all stopped containers, unused networks,
# dangling images, and build cache
# Are you sure? (yes/no):
```

### Docker Compose

```bash
# Basic commands
dcu                    # docker-compose up
dcud                   # docker-compose up -d (detached)
dcd                    # docker-compose down
dcr                    # docker-compose run
dce                    # docker-compose exec

# Build and restart
dcb                    # docker-compose build
dcrestart              # docker-compose restart

# Logs
dclogs                 # docker-compose logs
dclogsf                # docker-compose logs -f

# Helper - logs for specific service
dclogsvc web
# Shows logs for 'web' service

dclogsvc web -f
# Follow logs for 'web' service

# List containers
dcps                   # docker-compose ps
```

### Advanced Helpers

**Resource usage:**

```bash
# Show stats for all containers
dstats

# Show stats for specific container
dstats nginx
# Finds container matching "nginx" and shows stats
```

**Port mappings:**

```bash
# Show all port mappings
dports
# Table: NAMES, PORTS

# Show ports for specific container
dports nginx
# Shows port mappings for container matching "nginx"
```

**Inspect with jq (if installed):**

```bash
# Inspect container with JSON output
dinspectj nginx
# Pretty-prints JSON with jq

# Query specific fields
dinspectj nginx '.[0].NetworkSettings.IPAddress'
# Returns: "172.17.0.2"

dinspectj nginx '.[0].Config.Env'
# Shows environment variables
```

### Real Docker Workflow Example

```bash
# 1. Build custom image with git tag
dbuild-git myapp
# Builds with tags:
# - myapp:abc123 (git SHA)
# - myapp:main (branch)
# - myapp:latest

# 2. Run container
drun -d -p 8080:80 --name webapp myapp:latest

# 3. Check if it's running
dps

# 4. View logs
dlog webapp -f

# 5. Exec into container to debug
dex webapp
$ ps aux
$ curl localhost:80
$ cat /var/log/nginx/error.log
$ exit

# 6. Check resource usage
dstats webapp

# 7. Check port mappings
dports webapp

# 8. Inspect network config
dinspectj webapp '.[0].NetworkSettings'

# 9. Restart container
drestartn webapp

# 10. Clean up when done
dstopn webapp
drm webapp
```

---

## Git Workflows

### Basic Git Shortcuts

```bash
# Status
gs                     # git status
gss                    # git status -s (short format)

# Add and commit
ga file.txt            # git add file.txt
gaa                    # git add --all
gc                     # git commit
gcm "message"          # git commit -m "message"
gcam "message"         # git commit -am "message"

# Quick helpers
gcq "fix bug"          # Add all + commit
gcp-push "add feature" # Add all + commit + push
```

### Branching

```bash
# List branches
gb                     # git branch
gba                    # git branch -a (all branches)

# Create and switch
gco feature-branch     # git checkout feature-branch
gcob new-branch        # git checkout -b new-branch
gnb fix-login          # Helper: git checkout -b fix-login

# Switch to main/master
gcom                   # Tries main, falls back to master

# Delete branches
gbd feature-branch     # git branch -d feature-branch
gbD old-branch         # git branch -D old-branch (force)

# Delete local and remote
gbd-all feature-branch
# Deletes branch locally and on origin
```

### Viewing History

```bash
# Basic log
gl                     # git log
glo                    # git log --oneline
glog                   # git log --oneline --graph --decorate
gloga                  # git log --oneline --graph --decorate --all

# Detailed logs
gls                    # git log --stat
glp                    # git log -p (with patches)

# View recent branches
gbrecent
# Shows last 20 branches sorted by last commit

# Find commits
gfind "bug fix"
# Searches commit messages for "bug fix"

# View file history
ghistory README.md
# Shows all commits that changed README.md
```

### Diff Operations

```bash
# Diff unstaged changes
gd                     # git diff

# Diff staged changes
gds                    # git diff --staged

# Word-level diff
gdw                    # git diff --word-diff

# Diff between branches
gdiff-branch main feature
# Shows differences between main and feature
```

### Stash Operations

```bash
# Stash changes
gst                    # git stash
gstl                   # git stash list

# Apply stash
gsta                   # git stash apply
gstp                   # git stash pop

# Show stash contents
gsts                   # git stash show -p

# Drop stash
gstd                   # git stash drop
```

### Sync Operations

```bash
# Pull
gp                     # git pull
gpr                    # git pull --rebase

# Push
gpu                    # git push
gpuf                   # git push --force-with-lease (safer)
gpsup                  # git push --set-upstream origin <current-branch>

# Fetch
gf                     # git fetch
gfa                    # git fetch --all
```

### Undo Operations

```bash
# Undo last commit (keep changes)
gundo
# Runs: git reset --soft HEAD~1

# Undo last commit (discard changes - with confirmation)
gundohard
# WARNING: This will discard all changes from the last commit
# Are you sure? (yes/no):

# Reset to HEAD
grh                    # git reset HEAD
grhh                   # git reset --hard HEAD

# Reset to origin
groh                   # git reset --hard origin/<current-branch>
```

### Advanced Helpers

**Interactive rebase:**

```bash
# Rebase last N commits
gri-last 5
# Opens interactive rebase for last 5 commits

# Squash last N commits
gsquash 3 "Combined changes"
# Squashes last 3 commits into one with new message
```

**Repository info:**

```bash
# Show repository information
ginfo
# Output:
# Repository: dotfiles
# Branch: main
# Remote: git@github.com:drewnix/dotfiles.git
# Last commit: abc123 - Update README (2 hours ago)
#
# Status:
# M  README.md
# ?? new-file.txt
```

**Sync with main:**

```bash
# Update and rebase current branch on main
gsync
# 1. Fetches origin
# 2. Checks out main
# 3. Pulls latest
# 4. Checks out your branch
# 5. Rebases on main
```

**Clean merged branches:**

```bash
# Delete all merged branches (except main/master/develop)
gclean-merged
# Removes local branches that have been merged
```

### Real Git Workflow Example

```bash
# 1. Start new feature
gnb feature/user-auth
# Creates and switches to new branch

# 2. Make changes
vim src/auth.js
vim tests/auth.test.js

# 3. Check status
gs
# M  src/auth.js
# ?? tests/auth.test.js

# 4. Add and commit
gcq "Add user authentication"

# 5. Make more changes
vim src/auth.js

# 6. Amend last commit
ga src/auth.js
gcamendne              # Amend without editing message

# 7. View history
glog

# 8. Push to origin
gpsup
# Sets upstream and pushes

# 9. More commits...
gcq "Add tests"
gcq "Fix edge case"

# 10. Squash commits before PR
gri-last 3
# Interactive rebase to squash

# 11. Force push (safely)
gpuf

# 12. After PR is merged, cleanup
gcom                   # Back to main
gsync                  # Update main
gbd feature/user-auth  # Delete feature branch
gclean-merged          # Clean up other merged branches
```

---

## General Utilities

### Navigation Helpers

```bash
# Go up directories
..                     # cd ..
...                    # cd ../..
....                   # cd ../../..
up 4                   # cd ../../../..

# Directory bookmarks
dev                    # cd ~/dev
dl                     # cd ~/Downloads
dt                     # cd ~/Desktop
docs                   # cd ~/Documents
```

### File Search and Management

```bash
# Find files
ff config              # find . -type f -name "*config*"
fd logs                # find . -type d -name "*logs*"

# Quick find (case-insensitive)
qfind readme           # Finds README.md, readme.txt, etc.

# Grep in files
qgrep "TODO"           # Searches for "TODO" in all files
qgrep "error" "*.log"  # Only in .log files
```

### Archives

```bash
# Extract any archive
extract file.tar.gz
extract archive.zip
extract package.rar

# Create archives
targz output.tar.gz directory/
# Creates compressed tar.gz archive
```

### System Monitoring

```bash
# Process management
psg nginx              # ps aux | grep nginx
psme                   # Show processes for current user

# Kill by name
killp nginx            # Kills all processes matching "nginx"

# Network
ports                  # netstat -tulanp
listening              # Show listening ports
myip                   # Public IPv4
publicip               # Public IPv4 and IPv6
localip                # Local IP addresses
```

### Disk Usage

```bash
# Disk space
df                     # Disk usage summary
diskspace              # Formatted disk usage + largest dirs

# Directory sizes
duh                    # du -h --max-depth=1 | sort -h
dus                    # du -sh * | sort -h
dirsize /var/log       # Size of specific directory

# Find largest files
largest 10             # Top 10 largest files
largest 20 /var        # Top 20 in /var
```

### Utilities

```bash
# Calculator
calc "2 + 2"
calc "sqrt(144)"
calc "10 * 3.14159"

# Generate password
genpass                # 16 characters
genpass 32             # 32 characters

# Timer
timer 300              # 5 minute timer
timer 60               # 1 minute countdown

# JSON/YAML formatting
cat file.json | pjson  # Pretty-print JSON
pyaml file.yaml        # Pretty-print YAML (requires yq)

# Backup file
backup important.conf
# Creates: important.conf.backup-20240118-143022

# Weather
weather                # Weather for current location
weather Seattle        # Weather for Seattle
```

### Command History

Your shell maintains a **timestamped history** of 50,000 commands with smart deduplication and cross-session sharing.

**Basic history operations:**

```bash
# Reload shell config
reload                 # source ~/.zshrc

# Edit shell config
editrc                 # $EDITOR ~/.zshrc

# Show PATH
path
# Output (one per line):
# /home/andrew/.local/bin
# /usr/local/bin
# /usr/bin
# ...

# History stats
histats
# Shows most-used commands
```

**Advanced history search with timestamps:**

```bash
# Search history with timestamps
histime kubectl
# Output:
#  1247  2024-10-18 14:23  kubectl get pods -n production
#  1248  2024-10-18 14:24  kubectl delete pod api-server-xyz
#  1319  2024-10-18 16:45  kubectl logs -f web-app-abc123

# Show all commands from today
histoday
# Output:
# === Commands run today (2024-10-19) ===
#  1501  2024-10-19 08:15  git status
#  1502  2024-10-19 08:16  git commit -m "Update configs"
#  1503  2024-10-19 09:30  terraform plan

# Show commands from specific date
histdate 2024-10-15
# Output:
# === Commands run on 2024-10-15 ===
#  892  2024-10-15 09:15  terraform apply -auto-approve
#  893  2024-10-15 09:20  kubectl rollout status deployment/api

# Show commands from date range
histrange 2024-10-15 2024-10-18
# Shows all commands between these dates

# Audit trail - show all destructive commands
histaudit
# Output:
# === Potentially destructive commands ===
# Showing: delete, destroy, rm, remove, terminate, drop
#
#  1248  2024-10-18 14:24  kubectl delete pod api-server-xyz
#  1312  2024-10-18 15:30  aws ec2 terminate-instances --instance-ids i-abc123
#  1445  2024-10-19 10:15  rm -rf old-backups/

# Show top used commands with percentages
histop
# Output:
# === Top 20 most used commands ===
#  1  142  7.1%  kubectl
#  2  98   4.9%  git
#  3  76   3.8%  terraform
#  4  54   2.7%  aws
#  5  42   2.1%  docker

histop 10              # Show only top 10

# Export history to file (for audit/backup)
histexport
# Output:
# Exporting history to: history_export_20241019_083022.txt
# Exported 2847 commands

histexport audit.txt   # Custom filename
```

**Pro tips:**

```bash
# Secret protection - commands starting with space are NOT recorded
 export AWS_SECRET_ACCESS_KEY=supersecret123
 kubectl create secret generic db-pass --from-literal=password=secret

# These won't appear in history or histaudit
```

---

## Version Management with mise

### What is mise?

`mise` is a **fast** (10-100x faster than asdf) version manager for:

- Programming languages (Node.js, Python, Go, Ruby, etc.)
- CLI tools (Terraform, kubectl, Helm, etc.)
- Any tool with an asdf plugin

### Basic Usage

**Install tools globally:**

```bash
# Install latest version
mise use --global nodejs@latest
mise use --global python@latest

# Install specific version
mise use --global nodejs@20.11.0
mise use --global terraform@1.7.0

# Install LTS version
mise use --global nodejs@lts

# Multiple tools at once
mise use --global nodejs@20 python@3.12 golang@1.21
```

**List available tools:**

```bash
# Built-in tools (no plugins needed)
mise plugins ls-remote
# nodejs, python, golang, rust, terraform, kubectl, helm, etc.

# Available versions
mise ls-remote nodejs
mise ls-remote terraform
mise ls-remote python
```

**View installed tools:**

```bash
# Show all installed tools
mise ls

# Show tools in current directory
mise current
```

### Project-Specific Versions

**Using .tool-versions file:**

```bash
# In your project directory
cd ~/myproject

# Create .tool-versions
cat > .tool-versions << EOF
nodejs 20.11.0
terraform 1.7.0
python 3.12.1
EOF

# Install all tools from .tool-versions
mise install

# mise automatically switches versions when you cd into the directory!
cd ~/myproject        # Switches to nodejs 20.11.0
cd ~/other-project    # Switches to different versions
```

**Quick project setup:**

```bash
# Set versions for current directory
cd ~/myproject
mise use nodejs@20
mise use terraform@1.7.0

# This creates .tool-versions automatically
cat .tool-versions
# nodejs 20.11.0
# terraform 1.7.0
```

### mise Configuration

**Global config:** `~/.config/mise/config.toml`

```toml
# Already configured in your dotfiles

[settings]
jobs = 4                      # Parallel downloads
auto_install = true           # Auto-install missing tools
legacy_version_file = true    # Read .node-version, etc.

# Define global tools
[tools]
nodejs = "20.11.0"
python = "3.12.1"
terraform = "latest"
```

**Environment variables:**

```bash
# mise can manage env vars too
mise set NODE_ENV=development
mise set DATABASE_URL=postgres://localhost/mydb

# View env vars
mise env
```

### Common Workflows

**Node.js project:**

```bash
cd ~/my-node-app

# Use specific Node version
mise use nodejs@20.11.0

# Install dependencies
npm install

# Node version is automatically used
node --version
# v20.11.0
```

**Python project:**

```bash
cd ~/my-python-app

# Use Python 3.12
mise use python@3.12

# Create virtual env (mise + venv work together)
python -m venv venv
source venv/bin/activate

# Python version is automatically used
python --version
# Python 3.12.1
```

**Multi-language project:**

```bash
cd ~/fullstack-app

# Set multiple versions
mise use nodejs@20 python@3.12 golang@1.21

# Verify
mise current
# nodejs   20.11.0  ~/.tool-versions
# python   3.12.1   ~/.tool-versions
# golang   1.21.6   ~/.tool-versions
```

### Updating Tools

```bash
# Update mise itself
mise self-update

# Update all tools to latest
mise upgrade

# Update specific tool
mise upgrade nodejs

# List outdated tools
mise outdated
```

### Advanced Features

**Tasks (like npm scripts):**

```bash
# Define in .mise.toml
cat > .mise.toml << 'EOF'
[tasks.test]
run = "npm test"

[tasks.deploy]
run = "terraform apply -auto-approve"
EOF

# Run tasks
mise run test
mise run deploy
```

**Aliases:**

```bash
# Create aliases in config.toml
[aliases.nodejs]
lts = "20"
latest = "21"

# Use aliases
mise use nodejs@lts
```

---

## Starship Prompt

### What You See

Your prompt shows contextual information:

```text
╭─andrew@hostname ~/dotfiles main✗
├─⎈ prod-cluster(default) terraform:staging aws:prod gcp:my-project
╰─❯
```

**Line 1:** User, hostname, directory, git branch/status
**Line 2:** Kubernetes context, Terraform workspace, AWS profile, GCP project
**Line 3:** Command prompt

### Understanding the Symbols

**Git status:**

- `main` - Current branch
- `✗` - Uncommitted changes
- `⇡2` - 2 commits ahead of remote
- `⇣1` - 1 commit behind remote
- `+3` - 3 staged files
- `!2` - 2 modified files
- `?1` - 1 untracked file

**Kubernetes:**

- `⎈ prod-cluster(default)` - Context and namespace

**Cloud providers:**

- `☁️ production (us-west-2)` - AWS profile and region
- `🇬️ my-project` - GCP project

**Terraform:**

- `terraform:staging` - Current workspace

### Customizing Starship

Edit `~/.config/starship.toml`:

```toml
# Already configured in your dotfiles

# Change prompt character
[character]
success_symbol = "[➜](bold green)"  # Change this
error_symbol = "[✗](bold red)"

# Hide specific modules
[kubernetes]
disabled = true  # Don't show K8s context

# Change format
[aws]
format = 'AWS: [$profile]($style) '
```

**Reload after changes:**

```bash
# Starship reloads automatically, just start a new prompt
# Or restart terminal
```

### Useful Modules

All these are already configured:

- **directory** - Current path
- **git_branch** - Git branch name
- **git_status** - Git changes
- **kubernetes** - K8s context/namespace
- **terraform** - TF workspace
- **aws** - AWS profile/region
- **gcloud** - GCP project
- **docker_context** - Docker context
- **python** - Python version (from mise)
- **nodejs** - Node version (from mise)
- **golang** - Go version (from mise)
- **cmd_duration** - How long last command took
- **time** - Current time (right side)

---

## Tmux Terminal Multiplexer

### What is Tmux?

Tmux lets you:

- Split terminal into multiple panes
- Create multiple windows
- Detach and reattach sessions
- Keep sessions running when disconnected

### Basic Usage

**Prefix key:** ` (backtick)

```bash
# Start tmux
tmux
# Or: t (alias)

# Attach to existing session
tmux attach
# Or: ta (alias)

# List sessions
tmux ls
# Or: tls (alias)

# New named session
tmux new-session -s work
# Or: tns work (alias)

# Attach to named session
tmux attach -t work
# Or: tat work (alias)
```

### Window Management

All commands start with **prefix** (`) then a key:

```
`c          Create new window
`n          Next window
`p          Previous window
`0-9        Switch to window 0-9
`,          Rename window
`&          Kill window (with confirmation)
`w          List windows (interactive)
```

### Pane Management

```
`h          Split pane horizontally (left/right)
`v          Split pane vertically (top/bottom)
`o          Switch to next pane
`arrow      Switch pane in direction
`q          Show pane numbers
`x          Kill current pane
`z          Zoom pane (fullscreen toggle)
```

### Copy Mode (Vi bindings)

```
`[          Enter copy mode
space       Start selection
enter       Copy selection
`]          Paste

# In copy mode (vi-style):
h,j,k,l     Move cursor
w,b         Jump words
/           Search
n           Next search result
```

### Sessions

```
`d          Detach from session
`$          Rename session
`s          List sessions (interactive)
`(          Previous session
`)          Next session
```

### Useful Features

**Your tmux config includes:**

- **Mouse support** - Click to switch panes, scroll
- **System monitor** - CPU, RAM, disk in status bar
- **Catppuccin theme** - Beautiful colors
- **Vi bindings** - For copy mode
- **Plugin manager** - tpm for extensions

**Plugins installed:**

- `tmux-sensible` - Sensible defaults
- `catppuccin/tmux` - Theme
- `tmux-thumbs` - URL/file selection (press `f`)
- `tmux-mode-indicator` - Show current mode
- `tmux.nvim` - Neovim integration

### Real Tmux Workflow

```bash
# 1. Start session for project
tns myproject

# 2. Create windows for different tasks
`c          # New window
`,          # Rename to "editor"
vim

`c          # Another window
`,          # Rename to "server"
npm run dev

`c          # Another window
`,          # Rename to "logs"
tail -f logs/app.log

# 3. Split panes in logs window
`h          # Horizontal split
kubectl logs -f pod-name

# 4. Navigate between windows
`0          # Window 0 (editor)
`1          # Window 1 (server)
`2          # Window 2 (logs)

# 5. Detach (session keeps running)
`d

# 6. Later, reattach
tat myproject

# 7. Kill session when done
tmux kill-session -t myproject
```

---

## Security & Scanning Tools

### Trivy - Security Scanner

**What it does:** Scans containers, IaC, and filesystems for vulnerabilities and misconfigurations.

**When to use:** Before pushing images, in CI/CD, scanning Terraform/Kubernetes manifests.

**Basic usage:**

```bash
# Scan Docker image
trscan nginx:latest                    # Full scan
trscan-high myapp:v1.0                # Only HIGH/CRITICAL vulnerabilities

# Scan Terraform
trtf ./terraform                       # Scan Terraform directory
scan-terraform ./terraform             # Full TF scan with all tools

# Scan Kubernetes manifests
trk8s ./k8s                           # Scan K8s manifests
scan-k8s ./k8s                        # Full K8s manifest scan

# Scan for secrets in code
trfs-secret .                         # Scan filesystem for secrets
```

**Example workflow:**

```bash
# 1. Build Docker image
docker build -t myapp:v1.0 .

# 2. Scan for vulnerabilities
trscan myapp:v1.0
# Shows: CVEs, severity, affected packages

# 3. Scan for HIGH/CRITICAL only
trscan-high myapp:v1.0

# 4. If clean, push to registry
docker push myapp:v1.0
```

**Tips:**
- Use `.trivyignore` to suppress false positives
- Run in CI before deploying
- Scan IaC before applying changes

---

### Terraform Security Tools

**tfsec - Security scanner:**

```bash
# Scan current directory
tfsec

# Only serious issues
tfsec-high

# JSON output for CI
tfsec-json > report.json
```

**tflint - Linter:**

```bash
# Lint current directory
tfl

# Initialize plugins
tflinit

# Lint recursively
tflr
```

**Combined workflow:**

```bash
# Before terraform apply
tfl && tfsec                          # Lint + security scan
# Or use helper:
scan-terraform ./terraform            # Runs tflint, tfsec, and trivy
```

**Example findings:**

```bash
$ tfsec

aws-s3-enable-bucket-encryption
────────────────────────────────
  S3 Bucket does not have encryption enabled

  63 │     resource "aws_s3_bucket" "data" {
  64 │       bucket = "my-data-bucket"
  65 │     }
```

---

### Dive - Docker Image Analyzer

**What it does:** Shows layers in Docker images, identifies wasted space, calculates efficiency.

**Usage:**

```bash
# Analyze an image
dive myapp:v1.0

# CI mode (exit with error if inefficient)
diveci myapp:v1.0
```

**Interface:**
- **Tab** - Switch between layers and file tree
- **Ctrl+U** - Show only modified files
- **Ctrl+A** - Show added/modified/removed
- **Ctrl+F** - Filter files

**What to look for:**
1. **Efficiency score** - Aim for >90%
2. **Wasted space** - Duplicated files across layers
3. **Large files** - Unnecessary packages

**Optimization tips:**

```dockerfile
# ❌ Bad - Creates multiple layers
RUN apt-get update
RUN apt-get install -y nginx
RUN rm -rf /var/lib/apt/lists/*

# ✅ Good - Single layer, cleaned up
RUN apt-get update && \
    apt-get install -y nginx && \
    rm -rf /var/lib/apt/lists/*

# ✅ Better - Multi-stage build
FROM node:20 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
```

---

### yq - YAML Processor

**What it does:** Like jq but for YAML files. Essential for Kubernetes manifests.

**Common operations:**

```bash
# Read values
yqe '.spec.replicas' deployment.yaml

# Update values in-place
yqei '.spec.replicas = 5' deployment.yaml

# Convert YAML to JSON
yqjson deployment.yaml | jq .

# Extract from kubectl output
kubectl get pod mypod -o yaml | yqe '.spec.containers[0].image'
```

**Helper functions:**

```bash
# Read a field
yaml-get '.metadata.name' pod.yaml

# Update a field
yaml-set '.spec.replicas = 3' deployment.yaml

# Extract K8s secret
k8s-secret db-credentials password production
# Decodes base64 automatically
```

**Real-world examples:**

```bash
# Change all replicas in a directory
for f in k8s/*.yaml; do
  yaml-set '.spec.replicas = 5' "$f"
done

# Get all container images from deployments
kubectl get deployments -o yaml | \
  yqe '.items[].spec.template.spec.containers[].image'

# Update Helm values
yaml-set '.image.tag = "v2.0"' values.yaml
```

---

### Kubernetes Observability Tools

**kubetail - Multi-pod log tailing:**

```bash
# Tail logs from all pods matching pattern
kt nginx                              # All nginx pods
kt -n production api                  # In specific namespace
kts api                               # With timestamps
```

**popeye - Cluster sanitizer:**

```bash
# Scan cluster for issues
kpop

# Save report
kpop-save

# HTML report
kpop-html > report.html
```

**What popeye checks:**
- Over-allocated resources
- Dead/unused resources
- Security issues
- Missing probes
- Port mismatches

**kube-capacity - Resource analysis:**

```bash
# Show capacity across cluster
kcap

# Include actual utilization
kcap-util

# Specific namespace
kcap-util -n production

# Cost analysis
k8s-cost-analysis production
```

**Example output:**

```bash
$ kcap-util

NODE          CPU REQUESTS  CPU LIMITS  MEM REQUESTS  MEM LIMITS
node-1        60% / 70%     80% / 50%   70% / 65%     85% / 60%
  nginx-abc   10% / 5%      20% / 5%    15% / 10%     25% / 10%
  api-xyz     50% / 65%     60% / 45%   55% / 55%     60% / 50%

# First % = Requests, Second % = Actual Usage
```

**Cost optimization workflow:**

```bash
# 1. Check current utilization
kcap-util

# 2. Identify over-provisioned pods
# Look for: High requests, low usage

# 3. Check for missing limits
# Look for: Unlimited resources

# 4. Run popeye for recommendations
kpop

# 5. Adjust resource requests/limits
yaml-set '.spec.containers[0].resources.requests.cpu = "100m"' deployment.yaml

# 6. Apply and monitor
kubectl apply -f deployment.yaml
kcap-util  # Verify improvements
```

---

### kubectl Plugin Manager (krew)

**What it does:** Manages kubectl plugins (200+ available).

**Setup:**

```bash
# After bootstrap.sh installs krew, add to PATH:
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# Update plugin list
krew-update
```

**Recommended plugins:**

```bash
# Install useful plugins
kubectl krew install tree         # Show resource hierarchy
kubectl krew install neat         # Clean kubectl output
kubectl krew install view-secret  # Decode secrets easily
kubectl krew install ns           # Quick namespace switch
kubectl krew install ctx          # Quick context switch
```

**Usage examples:**

```bash
# Show resource tree
kubectl tree deployment nginx
# Shows: Deployment → ReplicaSet → Pods

# Clean output (remove managed fields)
kubectl get pod -o yaml | kubectl neat

# View secrets decoded
kubectl view-secret mysecret password
# No need for: kubectl get secret ... -o yaml | base64 -d

# Quick namespace/context switching
kubectl ns production              # Switch namespace
kubectl ctx staging                # Switch context
```

---

### AWS Vault - Secure Credentials

**What it does:** Stores AWS credentials in OS keychain instead of plaintext files.

**Setup:**

```bash
# Add credentials (stored encrypted)
av add production
# Enter Access Key ID: ...
# Enter Secret Access Key: ...

# List profiles
avl

# Remove profile
avrm old-profile
```

**Usage:**

```bash
# Execute single command
av exec production -- aws s3 ls

# Start shell with credentials
av exec production -- zsh
# Now all AWS commands use production creds

# Browser login (SSO)
av login production

# With MFA
av exec production --mfa-token=123456 -- aws s3 ls
```

**Integration with existing aliases:**

```bash
# Instead of:
awsp production
aws s3 ls

# Use:
av exec production -- aws s3 ls

# Or start a shell:
av exec production -- zsh
# Then use your aliases normally:
ec2-ls
s3-ls
```

**Security benefits:**
- Credentials never in plaintext
- OS keychain encryption
- MFA support
- Temporary session tokens
- Auto-rotation

---

### Security Audit Workflows

**Full project audit:**

```bash
# Run comprehensive security scan
security-audit

# This automatically detects and scans:
# - Docker images (trivy + dive)
# - Terraform (tflint + tfsec + trivy)
# - Kubernetes manifests (trivy)
# - Secrets in code (trivy)
```

**Pre-deployment checklist:**

```bash
# 1. Scan Docker image
trscan-high myapp:v1.0

# 2. Check image efficiency
dive myapp:v1.0

# 3. Scan infrastructure
scan-terraform ./terraform

# 4. Scan Kubernetes manifests
scan-k8s ./k8s

# 5. Check for secrets
trfs-secret .

# 6. If all clear, deploy
kubectl apply -f k8s/
```

**CI/CD integration:**

```bash
#!/bin/bash
# ci-security-check.sh

set -e

echo "Running security checks..."

# Fail on HIGH/CRITICAL vulnerabilities
trivy image --severity HIGH,CRITICAL --exit-code 1 myapp:latest

# Fail on Terraform security issues
tfsec --soft-fail=false ./terraform

# Fail on poor image efficiency (<80%)
CI=true dive myapp:latest

echo "✅ All security checks passed"
```

**Check tools installed:**

```bash
# Verify all security tools
check-security-tools

# Output:
# ✅ trivy - Security scanner for containers and IaC
# ✅ tfsec - Terraform security scanner
# ✅ tflint - Terraform linter
# ✅ dive - Docker image layer analyzer
# ✅ yq - YAML processor
# ❌ popeye - Kubernetes cluster sanitizer (not installed)
```

---

## Claude Code Integration

### Custom Slash Commands

Your dotfiles include pre-built commands in `.claude/commands/`:

**Available commands:**

- `/review` - Code security and best practices review
- `/k8s-debug` - Debug Kubernetes issues
- `/terraform-plan` - Review Terraform plans
- `/aws-policy` - Analyze AWS IAM policies

### Using Commands in Projects

**Set up in a project:**

```bash
# Copy to your project
cd ~/myproject
cp -r ~/dotfiles/claude/.claude .

# Now use commands
/review
/k8s-debug
```

### Example Usage

**Code review:**

```bash
# Make changes
vim src/app.js

# Review for security issues
/review
```

Claude will analyze:

- Security vulnerabilities
- Best practices violations
- Code organization
- Cloud-native concerns

**Kubernetes debugging:**

```bash
# When pod is failing
kubectl get pods
# NAME                   READY   STATUS             RESTARTS   AGE
# api-7d9f8c6b4d-x9k2m  0/1     CrashLoopBackOff   5          10m

/k8s-debug

# Provide context:
# "My api pod is in CrashLoopBackOff. Here are the logs: ..."
```

**Terraform review:**

```bash
# After planning
terraform plan -out=tfplan
terraform show tfplan

/terraform-plan

# Paste the plan output
```

Claude will check for:

- Security issues
- Cost optimization
- Best practices
- Compliance

### Creating Your Own Commands

**Create a new command:**

```bash
cd ~/dotfiles/claude/.claude/commands

cat > docker-optimize.md << 'EOF'
---
description: Optimize Dockerfile for security and size
---

Please review this Dockerfile and suggest optimizations for:

1. **Size Reduction**
   - Multi-stage builds
   - Layer optimization
   - Unnecessary packages

2. **Security**
   - Non-root user
   - Minimal base image
   - Vulnerability scanning

3. **Best Practices**
   - Cache utilization
   - Build speed
   - Reproducibility

Provide an improved version.
EOF

# Copy to project
cp -r ~/dotfiles/claude/.claude ~/myproject/

# Use it
cd ~/myproject
/docker-optimize
```

### Global Settings (Experimental)

Located in `~/dotfiles/claude/.config/claude/settings.json`:

```json
{
  "hooks": {
    "user-prompt-submit-hook": {
      "command": "echo 'Checking...'",
      "description": "Pre-submit validation",
      "enabled": false
    }
  }
}
```

Enable hooks for automatic checks before submitting prompts.

---

## Productivity Tips

### FZF Fuzzy Finder

FZF is integrated throughout your config:

**Built-in shortcuts:**

```bash
Ctrl-R         # Search command history
Ctrl-T         # Search files
Alt-C          # Search directories (cd into)
```

**Custom integrations:**

```bash
# AWS profile switcher
awsp-select    # Fuzzy search AWS profiles

# GCP project switcher
gproj-select   # Fuzzy search GCP projects

# Kubernetes context
kctx-fzf       # Fuzzy search K8s contexts (if you added this)
```

**Use in your own scripts:**

```bash
# Select file and edit
vim $(fzf)

# Select and delete
rm $(fzf -m)  # -m for multi-select

# Select directory
cd $(fd --type d | fzf)
```

### Shell History

**Better history with ZSH:**

```bash
# Your config includes:
# - 50,000 command history
# - Shared across sessions
# - Ignore duplicates
# - Ignore commands starting with space

# Search history
Ctrl-R                 # Fuzzy search with fzf

# History stats
histats               # Most-used commands
```

### Auto-Completion

**ZSH completions configured for:**

- kubectl (all resources and flags)
- terraform (commands and options)
- aws (services and commands)
- gcloud (all commands)
- docker (containers, images, networks)
- git (branches, remotes, files)

**Use tab completion:**

```bash
kubectl get <TAB>         # Shows all resource types
terraform <TAB>           # Shows all commands
aws ec2 <TAB>             # Shows ec2 subcommands
gcloud compute <TAB>      # Shows compute commands
```

### Autosuggestions

**ZSH autosuggestions:**

As you type, suggestions appear in gray:

```bash
# Type:
kubectl get p

# Suggestion appears:
kubectl get pods

# Press → to accept
```

### Syntax Highlighting

Commands are colored as you type:

- **Green** - Valid command
- **Red** - Invalid command or typo
- **Blue** - Directory
- **Cyan** - File

### Quick Shortcuts

**Most-used workflows:**

```bash
# Quick commit and push
gcq "message" && gpu

# Quick deploy
tfi && tfp && tfa

# Quick pod debug
kexe api && kubectl logs -f $(kubectl get pods | grep api | head -1 | awk '{print $1}')

# Quick instance SSH
ec2-ssh $(ec2-ls | grep web | head -1 | awk '{print $NF}')
```

---

## Real-World Workflows

### Full Stack Deployment

**Scenario:** Deploy new feature to production

```bash
# 1. Development
cd ~/myproject
gnb feature/new-api
vim src/api/users.js

# 2. Local testing
npm test
npm run dev

# 3. Commit
gcq "Add user API endpoint"

# 4. Build Docker image
dbuild-git myapp
# Tags: myapp:abc123, myapp:main, myapp:latest

# 5. Push to registry
docker tag myapp:abc123 gcr.io/myproject/myapp:abc123
docker push gcr.io/myproject/myapp:abc123

# 6. Update Kubernetes
vim k8s/deployment.yaml
# Change image to: gcr.io/myproject/myapp:abc123

# 7. Apply to staging
kctx staging
kns staging
kubectl apply -f k8s/

# 8. Watch rollout
kubectl rollout status deployment myapp

# 9. Check pods
kgp

# 10. View logs
klog myapp

# 11. Test
kubectl port-forward svc/myapp 8080:80
curl localhost:8080/api/users

# 12. Deploy to production
kctx production
kns production
kubectl apply -f k8s/
kubectl rollout status deployment myapp

# 13. Monitor
klog myapp

# 14. Verify
kubectl get pods
kubectl get svc

# 15. Push code
gpu
```

### Infrastructure Changes

**Scenario:** Add new RDS database with Terraform

```bash
# 1. Switch to infra workspace
cd ~/infrastructure
tfws staging

# 2. Create resource
vim terraform/rds.tf

# 3. Plan
tfp -out=plan.tfplan

# 4. Review with Claude
/terraform-plan
# Paste plan output

# 5. Apply to staging
tfa plan.tfplan

# 6. Test connectivity
aws rds describe-db-instances

# 7. Get endpoint
tfo | grep endpoint

# 8. Update application config
ssm-put /app/db-host $(tfo -raw db_endpoint)

# 9. Restart app pods
kgp
kubectl rollout restart deployment api

# 10. Verify
klog api | grep "Database connected"

# 11. If good, apply to production
tfws production
tfp -out=plan.tfplan
tfa plan.tfplan

# 12. Update prod config
ssm-put /prod/app/db-host $(tfo -raw db_endpoint)

# 13. Restart prod
kctx production
kubectl rollout restart deployment api

# 14. Monitor
klog api
```

### Debugging Production Issue

**Scenario:** API pods crashing in production

```bash
# 1. Check context
kinfo
# Context: production, Namespace: default

# 2. List pods
kgp
# api-7d9f8c6b4d-x9k2m  0/1  CrashLoopBackOff  5  10m

# 3. Get recent events
kgev | grep api

# 4. Check logs
klog api
# Error: Database connection refused

# 5. Describe pod
kdp api-7d9f8c6b4d-x9k2m
# Shows environment, volumes, etc.

# 6. Check database connection
ssm-get /prod/app/db-host
# rds.amazonaws.com

# 7. Test connectivity
kexe api
$ nc -zv rds.amazonaws.com 5432
# Connection timeout

# 8. Check security groups
aws ec2 describe-security-groups --filters "Name=tag:Name,Values=*rds*"

# 9. Found issue - security group not allowing EKS
# Fix in Terraform
vim terraform/rds.tf
# Add EKS security group to ingress

# 10. Apply fix
tfp
tfa

# 11. Wait for pods to restart
kubectl delete pod api-7d9f8c6b4d-x9k2m
kubectl get pods --watch

# 12. Verify logs
klog api
# Database connected successfully

# 13. Test endpoint
curl https://api.example.com/health
# {"status": "ok"}
```

### Multi-Cloud Migration

**Scenario:** Migrate workload from AWS to GCP

```bash
# 1. Set up GCP project
gcp-switch new-project

# 2. Create GKE cluster (Terraform)
cd ~/infrastructure/gcp
tfi
tfp
tfa

# 3. Get cluster credentials
gke-use new-cluster

# 4. Verify kubectl context
kinfo
# Context: gke_new-project_us-central1_new-cluster

# 5. Export AWS resources
kctx aws-prod
kubectl get deployment api -o yaml > aws-deployment.yaml
kubectl get service api -o yaml > aws-service.yaml
kubectl get configmap api-config -o yaml > aws-config.yaml

# 6. Modify for GCP
vim aws-deployment.yaml
# Update image registry: gcr.io instead of ECR

# 7. Apply to GCP
kctx gke-cluster
kubectl apply -f aws-deployment.yaml
kubectl apply -f aws-service.yaml
kubectl apply -f aws-config.yaml

# 8. Watch rollout
kubectl rollout status deployment api

# 9. Test in GCP
kgp
kgsvc
kubectl port-forward svc/api 8080:80
curl localhost:8080/health

# 10. Update DNS
gcloud dns record-sets transaction start --zone=example-com
gcloud dns record-sets transaction add \
  --name=api.example.com \
  --ttl=300 \
  --type=A \
  "$(kubectl get svc api -o jsonpath='{.status.loadBalancer.ingress[0].ip}')" \
  --zone=example-com
gcloud dns record-sets transaction execute --zone=example-com

# 11. Monitor both environments
# Terminal 1:
kctx aws-prod
klog api

# Terminal 2:
kctx gke-cluster
klog api

# 12. Gradually shift traffic, monitor metrics

# 13. After verification, decommission AWS
kctx aws-prod
kubectl delete -f aws-deployment.yaml
# Clean up Terraform resources
cd ~/infrastructure/aws
tfws production
tfd
```

---

## Troubleshooting

### Shell Issues

**Aliases not working:**

```bash
# Reload shell
source ~/.zshrc
# Or: reload

# Check if alias exists
alias | grep kubectl

# Check if module loaded
ls ~/.config/zsh/aliases/
cat ~/.config/zsh/aliases/kubernetes.zsh
```

**Completions not working:**

```bash
# Rebuild completion cache
rm ~/.zcompdump*
autoload -U compinit && compinit

# Restart shell
exec zsh
```

**Slow shell startup:**

```bash
# Profile shell startup
zsh -xv

# Check what's taking time
time zsh -i -c exit

# Disable modules temporarily
# Edit ~/.zshrc, comment out modules:
# [ -f ~/.config/zsh/aliases/kubernetes.zsh ] && source ...
```

### Tool Issues

**kubectl not found:**

```bash
# Check if installed
which kubectl

# Check PATH
echo $PATH | tr ':' '\n' | grep kubectl

# Reinstall
cd ~/dotfiles
./bootstrap.sh
```

**mise not activating:**

```bash
# Check if mise installed
which mise

# Check activation in zshrc
grep mise ~/.zshrc

# Manual activation
eval "$(mise activate zsh)"

# Verify
mise --version
```

**Starship not loading:**

```bash
# Check if installed
which starship

# Check init in zshrc
grep starship ~/.zshrc

# Manual init
eval "$(starship init zsh)"

# Check config
cat ~/.config/starship.toml
```

### Cloud Provider Issues

**AWS credentials not working:**

```bash
# Check credentials
aws-whoami
aws sts get-caller-identity

# Check config files
cat ~/.aws/credentials
cat ~/.aws/config

# Re-configure
aws configure
```

**GCP authentication expired:**

```bash
# Re-authenticate
gcloud auth login

# Check application credentials
gcloud auth application-default login

# Verify
gcp-whoami
```

**Kubernetes context wrong:**

```bash
# List contexts
kubectl config get-contexts

# Use correct context
kubectl config use-context correct-context

# Or use helper
kinfo
kctx correct-context
```

### Docker Issues

**Permission denied:**

```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Logout and login for changes to take effect
# Or:
newgrp docker
```

**Container not found:**

```bash
# List all containers
dpsa

# Check if stopped
docker ps -a | grep container-name

# Start if stopped
dstart container-name
```

### Tmux Issues

**Prefix not working:**

```bash
# Check tmux config
cat ~/.config/tmux/tmux.conf | grep prefix

# Verify tmux is reading config
tmux show-options -g | grep prefix

# Reload config
tmux source-file ~/.config/tmux/tmux.conf
```

**Plugins not working:**

```bash
# Install tpm (plugin manager)
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm

# In tmux, press:
prefix + I
# (backtick + Shift + i)
```

### Getting More Help

**Command documentation:**

```bash
# Built-in help
man kubectl
kubectl --help
terraform -help

# Cheat sheets
curl cheat.sh/kubectl
curl cheat.sh/docker
curl cheat.sh/git

# Tool versions
kubectl version
terraform version
aws --version
gcloud version
docker version
```

**Community resources:**

- [Kubernetes Docs](https://kubernetes.io/docs/)
- [Terraform Docs](https://www.terraform.io/docs)
- [AWS CLI Docs](https://docs.aws.amazon.com/cli/)
- [GCP Docs](https://cloud.google.com/docs)
- [Docker Docs](https://docs.docker.com/)

---

## Learning Path

### Week 1: Shell Basics

**Goals:**

- Get comfortable with basic navigation
- Learn essential aliases
- Understand the modular structure

**Practice:**

```bash
# Day 1-2: Navigation and files
cd ~/dotfiles
l                      # List files
.. && ..               # Go up directories
mkcd test && ls        # Create and enter directory
qfind README           # Find files
extract archive.zip    # Extract archives

# Day 3-4: Git basics
gs                     # Status
gco -b test-branch     # New branch
gcq "test commit"      # Commit
glog                   # View history
gundo                  # Undo commit

# Day 5-7: Customization
vim ~/.zshrc.local     # Add personal aliases
reload                 # Reload shell
alias                  # View all aliases
```

### Week 2: Kubernetes

**Goals:**

- Master basic kubectl operations
- Learn context/namespace switching
- Debug pods effectively

**Practice:**

```bash
# Day 1-2: Basic operations
kgp                    # Get pods
kgd                    # Get deployments
kgsvc                  # Get services
kinfo                  # Current context

# Day 3-4: Logs and debugging
klog pod-name          # View logs
kexe pod-name          # Exec into pod
kdp pod-name           # Describe pod
kgev                   # View events

# Day 5-7: Context switching
kcfggc                 # List contexts
kcfguc staging         # Switch context
kns production         # Switch namespace
```

### Week 3: Cloud Providers

**Goals:**

- Work with AWS CLI
- Understand GCP operations
- Manage resources efficiently

**Practice:**

```bash
# Day 1-3: AWS
aws-whoami             # Check identity
awsp dev               # Switch profile
ec2-ls                 # List instances
s3-ls                  # List buckets
eks-use cluster-name   # Update kubeconfig

# Day 4-7: GCP
gcp-whoami             # Check config
gproj-set project      # Switch project
gce-ls                 # List instances
gke-use cluster        # Get credentials
gsls                   # List GCS buckets
```

### Week 4: Infrastructure as Code

**Goals:**

- Master Terraform workflow
- Understand workspace management
- Work with state safely

**Practice:**

```bash
# Day 1-3: Basic workflow
tfi && tfp && tfa      # Full workflow
tfws staging           # Switch workspace
tfinfo                 # Workspace info
tfsl                   # List state

# Day 4-7: Advanced
tfwsp production       # Switch and plan
tfpvar prod.tfvars     # Plan with vars
tfvalidate-all         # Validate all
```

### Month 2: Advanced Workflows

**Week 5: Docker & Containers**
**Week 6: mise & Version Management**
**Week 7: Tmux & Productivity**
**Week 8: Real-world scenarios**

---

## Summary

This guide covered everything in your dotfiles setup:

**Tools & Aliases:**

- ✅ 200+ Kubernetes shortcuts
- ✅ Terraform workflow automation
- ✅ AWS CLI helpers
- ✅ GCP/gcloud operations
- ✅ Docker & container management
- ✅ Git productivity boosters
- ✅ General shell utilities

**Advanced Features:**

- ✅ mise version management
- ✅ Starship prompt customization
- ✅ Tmux multiplexing
- ✅ Claude Code integration
- ✅ FZF fuzzy finding

**Workflows:**

- ✅ Real-world deployment scenarios
- ✅ Debugging techniques
- ✅ Multi-cloud operations
- ✅ Infrastructure management

**Remember:**

- Use `<command> --help` for help
- Tab completion is your friend
- Functions without args show usage
- Experiment in dev/staging first
- Keep learning and customizing!

---

**Happy cloud-native development!** ☁️⚡

For issues or questions:

- GitHub: https://github.com/drewnix/dotfiles
- Email: andrew@drewnix.dev
