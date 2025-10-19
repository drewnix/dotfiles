# ╔══════════════════════════════════════════════════════════════╗
# ║ Terraform Aliases & Functions                                ║
# ╚══════════════════════════════════════════════════════════════╝

# Core terraform commands
alias tf='terraform'
alias tfi='terraform init'
alias tfiu='terraform init -upgrade'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfaa='terraform apply -auto-approve'
alias tfd='terraform destroy'
alias tfda='terraform destroy -auto-approve'
alias tfo='terraform output'
alias tfs='terraform show'
alias tfv='terraform validate'
alias tff='terraform fmt'
alias tffr='terraform fmt -recursive'
alias tfg='terraform graph'
alias tft='terraform test'
alias tfr='terraform refresh'
alias tfst='terraform state'

# Workspace management
alias tfw='terraform workspace'
alias tfwl='terraform workspace list'
alias tfws='terraform workspace select'
alias tfwn='terraform workspace new'
alias tfwd='terraform workspace delete'
alias tfwsh='terraform workspace show'

# State management
alias tfsl='terraform state list'
alias tfss='terraform state show'
alias tfsrm='terraform state rm'
alias tfsmv='terraform state mv'
alias tfsp='terraform state pull'
alias tfspu='terraform state push'

# Import/taint
alias tfim='terraform import'
alias tftaint='terraform taint'
alias tfuntaint='terraform untaint'

# OpenTofu (terraform fork) aliases if installed
if command -v tofu &> /dev/null; then
  alias to='tofu'
  alias toi='tofu init'
  alias top='tofu plan'
  alias toa='tofu apply'
  alias tod='tofu destroy'
  alias too='tofu output'
  alias tos='tofu show'
  alias tov='tofu validate'
  alias tof='tofu fmt'
fi

# terragrunt support
if command -v terragrunt &> /dev/null; then
  alias tg='terragrunt'
  alias tgi='terragrunt init'
  alias tgp='terragrunt plan'
  alias tga='terragrunt apply'
  alias tgaa='terragrunt apply -auto-approve'
  alias tgd='terragrunt destroy'
  alias tgo='terragrunt output'
  alias tgra='terragrunt run-all'
  alias tgrap='terragrunt run-all plan'
  alias tgraa='terragrunt run-all apply'
  alias tgrad='terragrunt run-all destroy'
fi

# ╔══════════════════════════════════════════════════════════════╗
# ║ Terraform Helper Functions                                   ║
# ╚══════════════════════════════════════════════════════════════╝

# Initialize, plan, and apply in one go
tfipa() {
  echo "Running: terraform init && terraform plan && terraform apply"
  terraform init && terraform plan && terraform apply
}

# Quick plan with colored output
tfpc() {
  terraform plan -out=tfplan && \
  terraform show -no-color tfplan | \
  landscape && \
  rm tfplan
}

# Switch workspace and plan
tfwsp() {
  if [ -z "$1" ]; then
    echo "Usage: tfwsp <workspace>"
    return 1
  fi
  terraform workspace select "$1" && terraform plan
}

# Format all terraform files recursively
tfall-fmt() {
  find . -name "*.tf" -exec terraform fmt {} \;
}

# Show current workspace and state info
tfinfo() {
  echo "Workspace: $(terraform workspace show)"
  echo "State resources: $(terraform state list | wc -l)"
  echo ""
  terraform state list
}

# Plan with variable file
tfpvar() {
  if [ -z "$1" ]; then
    echo "Usage: tfpvar <var-file>"
    return 1
  fi
  terraform plan -var-file="$1"
}

# Apply with variable file
tfavar() {
  if [ -z "$1" ]; then
    echo "Usage: tfavar <var-file>"
    return 1
  fi
  terraform apply -var-file="$1"
}

# Clean terraform cache/state backup files
tfclean() {
  echo "Cleaning terraform cache and backup files..."
  find . -type d -name ".terraform" -prune -exec rm -rf {} \;
  find . -type f -name "*.tfstate.backup" -delete
  find . -type f -name ".terraform.lock.hcl" -delete
  echo "Cleanup complete!"
}

# List all workspaces with resource counts
tfworkspaces() {
  echo "Terraform Workspaces:"
  local current_ws=$(terraform workspace show)
  terraform workspace list | while read ws; do
    ws=$(echo $ws | sed 's/\*//' | xargs)
    terraform workspace select $ws > /dev/null 2>&1
    local count=$(terraform state list 2>/dev/null | wc -l)
    if [ "$ws" = "$current_ws" ]; then
      echo "* $ws ($count resources)"
    else
      echo "  $ws ($count resources)"
    fi
  done
  terraform workspace select $current_ws > /dev/null 2>&1
}

# Validate all terraform in subdirectories
tfvalidate-all() {
  find . -type f -name "*.tf" -exec dirname {} \; | sort -u | while read dir; do
    echo "Validating: $dir"
    (cd "$dir" && terraform validate)
  done
}
