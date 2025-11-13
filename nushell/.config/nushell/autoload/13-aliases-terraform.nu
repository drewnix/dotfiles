# Terraform Aliases & Functions
# Terraform, Terragrunt, and IaC workflows

# ============================================================================
# Core Terraform Commands
# ============================================================================

alias tf = terraform
alias tfi = terraform init
alias tfiu = terraform init -upgrade
alias tfp = terraform plan
alias tfa = terraform apply
alias tfaa = terraform apply -auto-approve
alias tfd = terraform destroy
alias tfda = terraform destroy -auto-approve
alias tfo = terraform output
alias tfs = terraform show
alias tfv = terraform validate
alias tff = terraform fmt
alias tffr = terraform fmt -recursive
alias tfg = terraform graph
alias tft = terraform test
alias tfr = terraform refresh
alias tfst = terraform state

# ============================================================================
# Workspace Management
# ============================================================================

alias tfw = terraform workspace
alias tfwl = terraform workspace list
alias tfws = terraform workspace select
alias tfwn = terraform workspace new
alias tfwd = terraform workspace delete
alias tfwsh = terraform workspace show

# ============================================================================
# State Management
# ============================================================================

alias tfsl = terraform state list
alias tfss = terraform state show
alias tfsrm = terraform state rm
alias tfsmv = terraform state mv
alias tfsp = terraform state pull
alias tfspu = terraform state push

# ============================================================================
# Import/Taint
# ============================================================================

alias tfim = terraform import
alias tftaint = terraform taint
alias tfuntaint = terraform untaint

# ============================================================================
# OpenTofu (terraform fork) - if installed
# ============================================================================

if (which tofu | is-not-empty) {
    alias to = tofu
    alias toi = tofu init
    alias top = tofu plan
    alias toa = tofu apply
    alias tod = tofu destroy
    alias too = tofu output
    alias tos = tofu show
    alias tov = tofu validate
    alias tof = tofu fmt
}

# ============================================================================
# Terragrunt Support
# ============================================================================

if (which terragrunt | is-not-empty) {
    alias tg = terragrunt
    alias tgi = terragrunt init
    alias tgp = terragrunt plan
    alias tga = terragrunt apply
    alias tgaa = terragrunt apply -auto-approve
    alias tgd = terragrunt destroy
    alias tgo = terragrunt output
    alias tgra = terragrunt run-all
    alias tgrap = terragrunt run-all plan
    alias tgraa = terragrunt run-all apply
    alias tgrad = terragrunt run-all destroy
}

# ============================================================================
# Linting and Security Tools
# ============================================================================

# tflint - Terraform linter
if (which tflint | is-not-empty) {
    alias tfl = tflint
    alias tfli = tflint --init
    alias tflr = tflint --recursive
}

# tfsec - Terraform security scanner
if (which tfsec | is-not-empty) {
    alias tfsec = tfsec
    alias tfsec-all = tfsec .
}

# ============================================================================
# Terraform Helper Functions
# ============================================================================

# Initialize, plan, and apply in one go
def tfipa [] {
    print "Running: terraform init && terraform plan && terraform apply"
    terraform init
    terraform plan
    terraform apply
}

# Quick plan with colored output
def tfpc [] {
    terraform plan -out=tfplan

    # Show the plan
    terraform show tfplan

    # Clean up
    rm tfplan
}

# Switch workspace and plan
def tfwsp [workspace: string] {
    terraform workspace select $workspace
    terraform plan
}

# Format all terraform files recursively
def tfall-fmt [] {
    print "Formatting all .tf files recursively..."
    glob **/*.tf | each { |file|
        print $"Formatting ($file)"
        terraform fmt $file
    }
    print "Done!"
}

# Show current workspace and state info
def tfinfo [] {
    let workspace = (terraform workspace show | str trim)
    let resources = (terraform state list | lines | length)

    print $"Workspace: ($workspace)"
    print $"State resources: ($resources)"
    print ""
    terraform state list
}

# Plan with variable file
def tfpvar [varfile: string] {
    if not ($varfile | path exists) {
        print $"Error: Variable file '($varfile)' not found"
        return
    }
    terraform plan -var-file=$varfile
}

# Apply with variable file
def tfavar [varfile: string] {
    if not ($varfile | path exists) {
        print $"Error: Variable file '($varfile)' not found"
        return
    }
    terraform apply -var-file=$varfile
}

# Clean terraform cache/state backup files
def tfclean [] {
    print "Cleaning terraform cache and backup files..."

    # Remove .terraform directories
    let terraform_dirs = (glob **/.terraform)
    if ($terraform_dirs | is-not-empty) {
        $terraform_dirs | each { |dir|
            print $"Removing ($dir)"
            rm -rf $dir
        }
    }

    # Remove .tfstate.backup files
    let backup_files = (glob **/*.tfstate.backup)
    if ($backup_files | is-not-empty) {
        $backup_files | each { |file|
            print $"Removing ($file)"
            rm $file
        }
    }

    # Remove lock files
    let lock_files = (glob **/.terraform.lock.hcl)
    if ($lock_files | is-not-empty) {
        $lock_files | each { |file|
            print $"Removing ($file)"
            rm $file
        }
    }

    print "Cleanup complete!"
}

# List all workspaces with resource counts
def tfworkspaces [] {
    print "Terraform Workspaces:"

    let current_ws = (terraform workspace show | str trim)
    let workspaces = (terraform workspace list | lines | each { str trim | str replace '*' '' | str trim })

    for ws in $workspaces {
        # Switch to workspace
        terraform workspace select $ws | ignore

        # Count resources
        let count = (do -i { terraform state list } | complete | get stdout | lines | length)

        if $ws == $current_ws {
            print $"* ($ws) \(($count) resources)"
        } else {
            print $"  ($ws) \(($count) resources)"
        }
    }

    # Switch back to original workspace
    terraform workspace select $current_ws | ignore
}

# Validate all terraform in subdirectories
def tfvalidate-all [] {
    print "Validating all Terraform configurations..."

    let tf_dirs = (
        glob **/*.tf
        | each { path dirname }
        | uniq
        | sort
    )

    for dir in $tf_dirs {
        print $"Validating: ($dir)"
        cd $dir
        terraform validate
        cd -
    }

    print "Validation complete!"
}

# Get terraform version info
def tfversion [] {
    print "=== Terraform Version ==="
    terraform version

    if (which terragrunt | is-not-empty) {
        print "\n=== Terragrunt Version ==="
        terragrunt --version
    }

    if (which tflint | is-not-empty) {
        print "\n=== tflint Version ==="
        tflint --version
    }

    if (which tfsec | is-not-empty) {
        print "\n=== tfsec Version ==="
        tfsec --version
    }
}

# List all providers in use
def tf-providers [] {
    terraform providers
}

# Show terraform output as JSON
def tfo-json [] {
    terraform output -json | from json
}

# Get specific output value
def tfo-get [key: string] {
    let outputs = (terraform output -json | from json)
    if $key in $outputs {
        $outputs | get $key | get value
    } else {
        print $"Error: Output '($key)' not found"
    }
}

# Create a new terraform module
def tf-new-module [name: string] {
    mkdir $name
    cd $name

    # Create main.tf
    "# Main configuration for ($name) module\n" | save main.tf

    # Create variables.tf
    "# Input variables for ($name) module\n" | save variables.tf

    # Create outputs.tf
    "# Output values for ($name) module\n" | save outputs.tf

    # Create README.md
    $"# ($name)\n\nTerraform module for ($name)\n" | save README.md

    print $"Created new Terraform module: ($name)"
    ls
}

# List all resources in current state
def tf-resources [] {
    terraform state list
    | lines
    | parse "{type}.{name}"
    | group-by type
    | transpose key value
    | rename resource_type instances
    | insert count { |row| $row.instances | length }
    | select resource_type count instances
}

# Show resource by pattern
def tf-find [pattern: string] {
    terraform state list
    | lines
    | where $it =~ $pattern
}

# Unlock terraform state (force)
def tf-unlock [lock_id: string] {
    print $"Unlocking terraform state with lock ID: ($lock_id)"
    terraform force-unlock -force $lock_id
}

# Scan terraform with tfsec (if installed)
def scan-terraform [dir: string = "."] {
    if (which tfsec | is-empty) {
        print "Error: tfsec not installed"
        return
    }

    print $"Scanning ($dir) with tfsec..."
    tfsec $dir
}

# Lint terraform with tflint (if installed)
def lint-terraform [dir: string = "."] {
    if (which tflint | is-empty) {
        print "Error: tflint not installed"
        return
    }

    print $"Linting ($dir) with tflint..."
    cd $dir
    tflint --init
    tflint
    cd -
}

# Combined security and lint check
def tf-check [] {
    print "=== Running Terraform Checks ==="

    print "\n[1/3] Validating..."
    terraform validate

    if (which tflint | is-not-empty) {
        print "\n[2/3] Linting with tflint..."
        tflint
    }

    if (which tfsec | is-not-empty) {
        print "\n[3/3] Security scanning with tfsec..."
        tfsec .
    }

    print "\n=== Terraform checks complete ==="
}

# Show terraform cost estimate (if infracost is installed)
if (which infracost | is-not-empty) {
    def tf-cost [] {
        print "Generating cost estimate..."
        terraform plan -out=tfplan.binary
        terraform show -json tfplan.binary | save tfplan.json
        infracost breakdown --path tfplan.json
        rm tfplan.binary tfplan.json
    }
}

# Initialize workspace-specific backend config
def tfi-backend [backend_config: string] {
    if not ($backend_config | path exists) {
        print $"Error: Backend config '($backend_config)' not found"
        return
    }
    terraform init -backend-config=$backend_config
}

# Refresh and show outputs
def tf-refresh-outputs [] {
    terraform refresh
    terraform output
}
