# Steampipe Configuration

SQL interface for querying cloud APIs and services.

## What's Included

### Configuration Files (`.spc`)

Located in `~/.steampipe/config/`:

- **default.spc** - General options and terminal settings
- **aws.spc** - AWS connections using profiles
- **kubernetes.spc** - K8s connections using kubeconfig contexts
- **gcp.spc** - GCP connections using gcloud config
- **github.spc** - GitHub API access (requires GITHUB_TOKEN)
- **terraform.spc** - Terraform file analysis
- **docker.spc** - Local Docker daemon queries

### Query Library

Pre-built SQL queries in `~/.steampipe/config/queries/`:

- **aws-security.sql** - AWS security audits (IAM, S3, EC2, RDS, etc.)
- **kubernetes-security.sql** - K8s security checks (pods, RBAC, secrets)
- **cost-optimization.sql** - Find cost savings opportunities
- **inventory.sql** - Multi-cloud infrastructure inventory

### Plugin Installation Script

Run `~/.steampipe/install-plugins.sh` or use the `sp-setup` alias after stowing.

## Quick Start

### 1. Stow the Configuration

```bash
cd ~/dotfiles
./dotfiles.sh steampipe
```

### 2. Install Steampipe

```bash
./bootstrap.sh --full
```

Or manually:
```bash
sudo /bin/sh -c "$(curl -fsSL https://steampipe.io/install/steampipe.sh)"
```

### 3. Install Plugins

```bash
sp-setup
# Or manually:
steampipe plugin install
```

### 4. Set Environment Variables

For GitHub plugin:
```bash
export GITHUB_TOKEN="ghp_your_token_here"
```

For AWS (if using aws-vault):
```bash
av exec production -- steampipe query
```

## Usage

### Aliases (from security.zsh)

**Service management:**
```bash
sps              # Start service
spx              # Stop service
spr              # Restart service
spstat           # Service status
```

**Quick queries:**
```bash
sp-aws-mfa       # Find IAM users without MFA
sp-aws-s3        # Find public S3 buckets
sp-k8s-priv      # Find privileged K8s pods
sp-cost-ebs      # Find unattached EBS volumes
```

**Query libraries:**
```bash
sp-aws-security  # Run all AWS security checks
sp-k8s-security  # Run all K8s security checks
sp-cost-opt      # Run all cost optimization queries
sp-inventory     # Run multi-cloud inventory
```

**Interactive:**
```bash
sp-shell         # Start interactive SQL shell
sp "SELECT ..."  # Run ad-hoc query
```

### Custom Queries

Create `.sql` files in `~/.steampipe/config/queries/` and run them:

```bash
sp-run my-query.sql
```

Or use the helper function:
```bash
sp "SELECT instance_id, instance_type FROM aws_ec2_instance WHERE instance_state = 'running'"
```

## Adding More Plugins

Edit configuration files to add more connections, then run:

```bash
steampipe plugin install
```

Popular plugins:
- `steampipe plugin install azure`
- `steampipe plugin install datadog`
- `steampipe plugin install slack`
- `steampipe plugin install gitlab`

See all available plugins: https://hub.steampipe.io/plugins

## Customization

### Add New Connections

Edit `~/.steampipe/config/aws.spc`:

```hcl
connection "aws_prod" {
  plugin = "aws"
  profile = "production"
  regions = ["us-east-1", "us-west-2"]
}
```

### Create Query Libraries

Create `~/.steampipe/config/queries/my-queries.sql`:

```sql
-- My custom security checks
select
  name,
  mfa_enabled
from
  aws_iam_user
where
  mfa_enabled = false;
```

Run with: `sp-run my-queries.sql`

### Aggregate Multiple Accounts

```hcl
connection "aws_all" {
  plugin = "aws"
  type = "aggregator"
  connections = ["aws_prod", "aws_dev", "aws_staging"]
}
```

## Documentation

- Steampipe docs: https://steampipe.io/docs
- Plugin hub: https://hub.steampipe.io/plugins
- Query examples: https://steampipe.io/docs/sql/steampipe-sql
- Mod library: https://hub.steampipe.io/mods

## Troubleshooting

### Plugins not installing

```bash
# Check service status
steampipe service status

# Restart service
steampipe service restart

# Manually install
steampipe plugin install aws
```

### Connection errors

```bash
# Check AWS credentials
aws sts get-caller-identity

# Check K8s context
kubectl config current-context

# Check GCP auth
gcloud auth list
```

### Query errors

```bash
# List available tables
sp ".tables"

# Inspect table schema
sp ".inspect aws_ec2_instance"

# Enable query timing
sp ".timing on"
```
