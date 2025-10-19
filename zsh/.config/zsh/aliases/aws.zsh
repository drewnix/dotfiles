# ╔══════════════════════════════════════════════════════════════╗
# ║ AWS CLI Aliases & Functions                                  ║
# ╚══════════════════════════════════════════════════════════════╝

# Core AWS CLI
alias aws='aws'
alias awsv='aws --version'

# EC2
alias ec2-ls='aws ec2 describe-instances --query "Reservations[].Instances[].[InstanceId,InstanceType,State.Name,PublicIpAddress,PrivateIpAddress,Tags[?Key==\`Name\`].Value|[0]]" --output table'
alias ec2-running='aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].[InstanceId,InstanceType,PublicIpAddress,Tags[?Key==\`Name\`].Value|[0]]" --output table'
alias ec2-start='aws ec2 start-instances --instance-ids'
alias ec2-stop='aws ec2 stop-instances --instance-ids'
alias ec2-terminate='aws ec2 terminate-instances --instance-ids'

# S3
alias s3-ls='aws s3 ls'
alias s3-mb='aws s3 mb'
alias s3-rb='aws s3 rb'
alias s3-cp='aws s3 cp'
alias s3-sync='aws s3 sync'
alias s3-buckets='aws s3api list-buckets --query "Buckets[].Name" --output table'

# ECS
alias ecs-clusters='aws ecs list-clusters --output table'
alias ecs-services='aws ecs list-services --cluster'
alias ecs-tasks='aws ecs list-tasks --cluster'

# EKS
alias eks-clusters='aws eks list-clusters --output table'
alias eks-kubeconfig='aws eks update-kubeconfig --name'
alias eks-nodegroups='aws eks list-nodegroups --cluster-name'

# Lambda
alias lambda-ls='aws lambda list-functions --query "Functions[].[FunctionName,Runtime,LastModified]" --output table'
alias lambda-invoke='aws lambda invoke --function-name'

# IAM
alias iam-users='aws iam list-users --query "Users[].[UserName,CreateDate]" --output table'
alias iam-roles='aws iam list-roles --query "Roles[].[RoleName,CreateDate]" --output table'
alias iam-policies='aws iam list-policies --scope Local --query "Policies[].[PolicyName,CreateDate]" --output table'
alias iam-whoami='aws sts get-caller-identity'

# CloudFormation
alias cf-stacks='aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE --query "StackSummaries[].[StackName,StackStatus,CreationTime]" --output table'
alias cf-events='aws cloudformation describe-stack-events --stack-name'
alias cf-resources='aws cloudformation describe-stack-resources --stack-name'

# CloudWatch Logs
alias logs-groups='aws logs describe-log-groups --query "logGroups[].[logGroupName,creationTime]" --output table'
alias logs-tail='aws logs tail'
alias logs-tail-follow='aws logs tail --follow'

# Systems Manager
alias ssm-params='aws ssm describe-parameters --query "Parameters[].[Name,Type,LastModifiedDate]" --output table'
alias ssm-get='aws ssm get-parameter --name'
alias ssm-gets='aws ssm get-parameter --name --with-decryption'
alias ssm-sessions='aws ssm describe-sessions --state Active'
alias ssm-start='aws ssm start-session --target'

# Secrets Manager
alias secrets-ls='aws secretsmanager list-secrets --query "SecretList[].[Name,LastChangedDate]" --output table'
alias secrets-get='aws secretsmanager get-secret-value --secret-id'

# RDS
alias rds-ls='aws rds describe-db-instances --query "DBInstances[].[DBInstanceIdentifier,DBInstanceClass,Engine,DBInstanceStatus]" --output table'
alias rds-clusters='aws rds describe-db-clusters --query "DBClusters[].[DBClusterIdentifier,Engine,Status]" --output table'

# VPC
alias vpc-ls='aws ec2 describe-vpcs --query "Vpcs[].[VpcId,CidrBlock,Tags[?Key==\`Name\`].Value|[0]]" --output table'
alias subnet-ls='aws ec2 describe-subnets --query "Subnets[].[SubnetId,VpcId,CidrBlock,AvailabilityZone,Tags[?Key==\`Name\`].Value|[0]]" --output table'
alias sg-ls='aws ec2 describe-security-groups --query "SecurityGroups[].[GroupId,GroupName,VpcId]" --output table'

# Route53
alias r53-zones='aws route53 list-hosted-zones --query "HostedZones[].[Name,Id]" --output table'

# Cost Explorer
alias aws-cost-today='aws ce get-cost-and-usage --time-period Start=$(date +%Y-%m-01),End=$(date +%Y-%m-%d) --granularity MONTHLY --metrics BlendingCost'

# Profile management
alias awsp='export AWS_PROFILE='
alias awspl='aws configure list-profiles'

# aws-vault support (if installed)
if command -v aws-vault &> /dev/null; then
  alias av='aws-vault'
  alias avl='aws-vault list'
  alias ave='aws-vault exec'
  alias avr='aws-vault remove'
  alias avs='aws-vault login'
fi

# ╔══════════════════════════════════════════════════════════════╗
# ║ AWS Helper Functions                                         ║
# ╚══════════════════════════════════════════════════════════════╝

# Quick AWS account info
aws-whoami() {
  echo "AWS Identity Information:"
  aws sts get-caller-identity --output table
  echo "\nCurrent Region: ${AWS_REGION:-$(aws configure get region)}"
  echo "Current Profile: ${AWS_PROFILE:-default}"
}

# Switch AWS profile with fuzzy search (requires fzf)
awsp-select() {
  if command -v fzf &> /dev/null; then
    local profile=$(aws configure list-profiles | fzf --height 40% --reverse)
    if [ -n "$profile" ]; then
      export AWS_PROFILE=$profile
      echo "Switched to AWS profile: $profile"
      aws-whoami
    fi
  else
    echo "Error: fzf is required for this function"
    echo "Available profiles:"
    aws configure list-profiles
  fi
}

# Get EC2 instance ID by name tag
ec2-id() {
  if [ -z "$1" ]; then
    echo "Usage: ec2-id <name-tag>"
    return 1
  fi
  aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=*$1*" "Name=instance-state-name,Values=running" \
    --query "Reservations[].Instances[].[InstanceId,Tags[?Key=='Name'].Value|[0]]" \
    --output table
}

# SSH into EC2 instance by name
ec2-ssh() {
  if [ -z "$1" ]; then
    echo "Usage: ec2-ssh <name-tag> [user]"
    return 1
  fi
  local user="${2:-ec2-user}"
  local ip=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=*$1*" "Name=instance-state-name,Values=running" \
    --query "Reservations[0].Instances[0].PublicIpAddress" \
    --output text)

  if [ "$ip" != "None" ] && [ -n "$ip" ]; then
    echo "Connecting to $ip as $user"
    ssh $user@$ip
  else
    echo "No running instance found with name: $1"
  fi
}

# SSM connect to EC2 instance by name
ec2-ssm() {
  if [ -z "$1" ]; then
    echo "Usage: ec2-ssm <name-tag>"
    return 1
  fi
  local instance_id=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=*$1*" "Name=instance-state-name,Values=running" \
    --query "Reservations[0].Instances[0].InstanceId" \
    --output text)

  if [ "$instance_id" != "None" ] && [ -n "$instance_id" ]; then
    echo "Connecting to instance: $instance_id"
    aws ssm start-session --target $instance_id
  else
    echo "No running instance found with name: $1"
  fi
}

# Update EKS kubeconfig by cluster name pattern
eks-use() {
  if [ -z "$1" ]; then
    echo "Usage: eks-use <cluster-name>"
    return 1
  fi

  local cluster=$(aws eks list-clusters --output text --query 'clusters[]' | tr '\t' '\n' | grep -i "$1" | head -1)
  if [ -n "$cluster" ]; then
    echo "Updating kubeconfig for cluster: $cluster"
    aws eks update-kubeconfig --name "$cluster"
  else
    echo "No cluster found matching: $1"
    echo "\nAvailable clusters:"
    aws eks list-clusters --output table
  fi
}

# Get CloudWatch logs for Lambda function
lambda-logs() {
  if [ -z "$1" ]; then
    echo "Usage: lambda-logs <function-name> [minutes-ago]"
    return 1
  fi
  local minutes="${2:-60}"
  local log_group="/aws/lambda/$1"
  echo "Tailing logs for $log_group (last $minutes minutes)..."
  aws logs tail "$log_group" --since "${minutes}m" --follow
}

# Empty S3 bucket (be careful!)
s3-empty() {
  if [ -z "$1" ]; then
    echo "Usage: s3-empty <bucket-name>"
    return 1
  fi
  echo "WARNING: This will delete all objects in s3://$1"
  read "response?Are you sure? (yes/no): "
  if [ "$response" = "yes" ]; then
    aws s3 rm "s3://$1" --recursive
    echo "Bucket emptied: $1"
  else
    echo "Aborted"
  fi
}

# List all AWS regions
aws-regions() {
  aws ec2 describe-regions --query "Regions[].[RegionName]" --output text | sort
}

# Switch AWS region
aws-region() {
  if [ -z "$1" ]; then
    echo "Current region: ${AWS_REGION:-$(aws configure get region)}"
    echo "\nAvailable regions:"
    aws-regions
    return 0
  fi
  export AWS_REGION=$1
  echo "Switched to region: $1"
}

# Get parameter store values by path
ssm-get-path() {
  if [ -z "$1" ]; then
    echo "Usage: ssm-get-path <path>"
    return 1
  fi
  aws ssm get-parameters-by-path --path "$1" --recursive --with-decryption \
    --query "Parameters[].[Name,Value]" --output table
}
