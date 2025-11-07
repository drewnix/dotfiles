# ✅ Steampipe Integration Complete!

## What Was Added

### 1. Steampipe Stow Package (`steampipe/`)

```
steampipe/
├── .steampipe/
│   ├── install-plugins.sh       # Plugin installer
│   └── config/
│       ├── default.spc          # General options
│       ├── aws.spc              # AWS connections
│       ├── kubernetes.spc       # K8s connections
│       ├── gcp.spc              # GCP connections
│       ├── github.spc           # GitHub API
│       ├── terraform.spc        # Terraform analysis
│       ├── docker.spc           # Docker queries
│       └── queries/
│           ├── aws-security.sql       # AWS security audits
│           ├── kubernetes-security.sql # K8s security checks
│           ├── cost-optimization.sql  # Cost savings
│           └── inventory.sql          # Multi-cloud inventory
└── README.md                    # Package documentation
```

### 2. Bootstrap Integration

- Added steampipe installation to `bootstrap.sh` (line 345-355)
- Installs with `./bootstrap.sh --full`
- Already installed on your system (v2.3.2)

### 3. Dotfiles Integration

- Added to `dotfiles.sh` ALL_PACKAGES and DEFAULT_PACKAGES
- Auto-stows with `./dotfiles.sh` or `./dotfiles.sh --all`

### 4. ZSH Aliases (security.zsh)

**Service management:**
- `sp` - Run query
- `sps` - Start service
- `spx` - Stop service
- `spr` - Restart service
- `spstat` - Service status

**Quick security queries:**
- `sp-aws-mfa` - IAM users without MFA
- `sp-aws-s3` - Public S3 buckets
- `sp-k8s-priv` - Privileged pods
- `sp-cost-ebs` - Unattached EBS volumes

**Query libraries:**
- `sp-aws-security` - Full AWS audit
- `sp-k8s-security` - Full K8s audit
- `sp-cost-opt` - Cost optimization
- `sp-inventory` - Multi-cloud inventory

**Utilities:**
- `sp-shell` - Interactive SQL shell
- `sp-setup` - Install all plugins
- `sp-run <file>` - Run query from file

### 5. Verification Script

- Updated `scripts/verify-tools.sh` to check steampipe
- Already passing: ✅ steampipe v2.3.2

### 6. Documentation

- Updated `CLAUDE.md` with Steampipe architecture notes
- Added workflow examples
- Created comprehensive `steampipe/README.md`

## Next Steps

### 1. Stow the Configuration

```bash
cd ~/dotfiles
./dotfiles.sh steampipe
```

This will create symlinks from `~/dotfiles/steampipe/.steampipe/` to `~/.steampipe/`

### 2. Install Plugins

```bash
sp-setup
```

This will:
- Start the Steampipe service
- Read all `.spc` config files
- Install referenced plugins (aws, gcp, kubernetes, github, terraform, docker)
- Display installed plugin list

### 3. Configure Credentials

**AWS:**
```bash
aws configure
# Or with aws-vault:
av add production
```

**GCP:**
```bash
gcloud auth login
gcloud config set project my-project
```

**GitHub:**
```bash
export GITHUB_TOKEN="ghp_your_token_here"
# Add to ~/.secrets for persistence
```

**Kubernetes:**
- Already configured (uses current kubeconfig context)

### 4. Test Queries

```bash
# Interactive shell
sp-shell

# Quick queries
sp-aws-mfa
sp-k8s-pods

# Full audits
sp-aws-security
sp-k8s-security

# Custom query
sp "select instance_id, instance_state from aws_ec2_instance"
```

## Example Workflows

### Security Audit

```bash
# Check AWS security
sp-aws-security

# Check K8s security
sp-k8s-security

# Find cost savings
sp-cost-opt

# View inventory
sp-inventory
```

### Ad-Hoc Queries

```bash
# Find all running EC2 instances
sp "select instance_id, instance_type, region from aws_ec2_instance where instance_state = 'running'"

# Find K8s pods in crashloop
sp "select name, namespace from kubernetes_pod where phase = 'Failed'"

# Find public S3 buckets
sp "select name, region from aws_s3_bucket where bucket_policy_is_public = true"
```

### Multi-Account Queries

Edit `~/.steampipe/config/aws.spc` to add multiple accounts:

```hcl
connection "aws_prod" {
  plugin = "aws"
  profile = "production"
}

connection "aws_dev" {
  plugin = "aws"
  profile = "development"
}

connection "aws_all" {
  plugin = "aws"
  type = "aggregator"
  connections = ["aws_prod", "aws_dev"]
}
```

Then query across all accounts:
```bash
sp "select account_id, count(*) from aws_all.aws_ec2_instance group by account_id"
```

## Files Modified

1. ✅ `bootstrap.sh` - Added steampipe installation
2. ✅ `dotfiles.sh` - Added steampipe package
3. ✅ `scripts/verify-tools.sh` - Added steampipe check
4. ✅ `zsh/.config/zsh/aliases/security.zsh` - Added aliases and functions
5. ✅ `CLAUDE.md` - Updated documentation

## Files Created

1. ✅ `steampipe/.steampipe/config/default.spc`
2. ✅ `steampipe/.steampipe/config/aws.spc`
3. ✅ `steampipe/.steampipe/config/kubernetes.spc`
4. ✅ `steampipe/.steampipe/config/gcp.spc`
5. ✅ `steampipe/.steampipe/config/github.spc`
6. ✅ `steampipe/.steampipe/config/terraform.spc`
7. ✅ `steampipe/.steampipe/config/docker.spc`
8. ✅ `steampipe/.steampipe/config/queries/aws-security.sql`
9. ✅ `steampipe/.steampipe/config/queries/kubernetes-security.sql`
10. ✅ `steampipe/.steampipe/config/queries/cost-optimization.sql`
11. ✅ `steampipe/.steampipe/config/queries/inventory.sql`
12. ✅ `steampipe/install-plugins.sh`
13. ✅ `steampipe/README.md`

## Resources

- Steampipe Docs: https://steampipe.io/docs
- Plugin Hub: https://hub.steampipe.io/plugins
- Mod Library: https://hub.steampipe.io/mods
- SQL Reference: https://steampipe.io/docs/sql/steampipe-sql

## Quick Reference

```bash
# Service
sps              # Start
spx              # Stop
spr              # Restart

# Queries
sp-shell         # Interactive
sp "SELECT ..."  # Ad-hoc
sp-run file.sql  # From file

# Audits
sp-aws-security  # AWS
sp-k8s-security  # K8s
sp-cost-opt      # Cost
sp-inventory     # Inventory

# Plugins
sp-setup         # Install all
spinstall aws    # Install one
spupdate         # Update all
spplugin list    # List installed
```
