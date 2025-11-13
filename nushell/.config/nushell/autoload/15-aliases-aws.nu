# ╔══════════════════════════════════════════════════════════════╗
# ║ AWS CLI Aliases & Functions                                  ║
# ╚══════════════════════════════════════════════════════════════╝

# Core AWS CLI aliases
export alias awsv = aws --version

# EC2 - Elastic Compute Cloud
export alias ec2-ls = aws ec2 describe-instances --query "Reservations[].Instances[].[InstanceId,InstanceType,State.Name,PublicIpAddress,PrivateIpAddress,Tags[?Key==`Name`].Value|[0]]" --output table
export alias ec2-running = aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].[InstanceId,InstanceType,PublicIpAddress,Tags[?Key==`Name`].Value|[0]]" --output table
export alias ec2-start = aws ec2 start-instances --instance-ids
export alias ec2-stop = aws ec2 stop-instances --instance-ids
export alias ec2-terminate = aws ec2 terminate-instances --instance-ids

# S3 - Simple Storage Service
export alias s3-ls = aws s3 ls
export alias s3-mb = aws s3 mb
export alias s3-rb = aws s3 rb
export alias s3-cp = aws s3 cp
export alias s3-sync = aws s3 sync
export alias s3-buckets = aws s3api list-buckets --query "Buckets[].Name" --output table

# ECS - Elastic Container Service
export alias ecs-clusters = aws ecs list-clusters --output table
export alias ecs-services = aws ecs list-services --cluster
export alias ecs-tasks = aws ecs list-tasks --cluster

# EKS - Elastic Kubernetes Service
export alias eks-clusters = aws eks list-clusters --output table
export alias eks-kubeconfig = aws eks update-kubeconfig --name
export alias eks-nodegroups = aws eks list-nodegroups --cluster-name

# Lambda - Serverless Functions
export alias lambda-ls = aws lambda list-functions --query "Functions[].[FunctionName,Runtime,LastModified]" --output table
export alias lambda-invoke = aws lambda invoke --function-name

# IAM - Identity and Access Management
export alias iam-users = aws iam list-users --query "Users[].[UserName,CreateDate]" --output table
export alias iam-roles = aws iam list-roles --query "Roles[].[RoleName,CreateDate]" --output table
export alias iam-policies = aws iam list-policies --scope Local --query "Policies[].[PolicyName,CreateDate]" --output table
export alias iam-whoami = aws sts get-caller-identity

# CloudFormation - Infrastructure as Code
export alias cf-stacks = aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE --query "StackSummaries[].[StackName,StackStatus,CreationTime]" --output table
export alias cf-events = aws cloudformation describe-stack-events --stack-name
export alias cf-resources = aws cloudformation describe-stack-resources --stack-name

# CloudWatch Logs - Logging and Monitoring
export alias logs-groups = aws logs describe-log-groups --query "logGroups[].[logGroupName,creationTime]" --output table
export alias logs-tail = aws logs tail
export alias logs-tail-follow = aws logs tail --follow

# Systems Manager - Parameter Store and Session Manager
export alias ssm-params = aws ssm describe-parameters --query "Parameters[].[Name,Type,LastModifiedDate]" --output table
export alias ssm-get = aws ssm get-parameter --name
export alias ssm-gets = aws ssm get-parameter --name --with-decryption
export alias ssm-sessions = aws ssm describe-sessions --state Active
export alias ssm-start = aws ssm start-session --target

# Secrets Manager - Secure Secrets Storage
export alias secrets-ls = aws secretsmanager list-secrets --query "SecretList[].[Name,LastChangedDate]" --output table
export alias secrets-get = aws secretsmanager get-secret-value --secret-id

# RDS - Relational Database Service
export alias rds-ls = aws rds describe-db-instances --query "DBInstances[].[DBInstanceIdentifier,DBInstanceClass,Engine,DBInstanceStatus]" --output table
export alias rds-clusters = aws rds describe-db-clusters --query "DBClusters[].[DBClusterIdentifier,Engine,Status]" --output table

# VPC - Virtual Private Cloud
export alias vpc-ls = aws ec2 describe-vpcs --query "Vpcs[].[VpcId,CidrBlock,Tags[?Key==`Name`].Value|[0]]" --output table
export alias subnet-ls = aws ec2 describe-subnets --query "Subnets[].[SubnetId,VpcId,CidrBlock,AvailabilityZone,Tags[?Key==`Name`].Value|[0]]" --output table
export alias sg-ls = aws ec2 describe-security-groups --query "SecurityGroups[].[GroupId,GroupName,VpcId]" --output table

# Route53 - DNS Service
export alias r53-zones = aws route53 list-hosted-zones --query "HostedZones[].[Name,Id]" --output table

# Profile management
export alias awspl = aws configure list-profiles

# aws-vault support (if installed)
export alias av = aws-vault
export alias avl = aws-vault list
export alias ave = aws-vault exec
export alias avr = aws-vault remove
export alias avs = aws-vault login

# ╔══════════════════════════════════════════════════════════════╗
# ║ AWS Helper Functions                                         ║
# ╚══════════════════════════════════════════════════════════════╝

# Quick AWS account info
export def aws-whoami [] {
  print "AWS Identity Information:"
  aws sts get-caller-identity --output table

  let region = if ($env.AWS_REGION? | is-empty) {
    aws configure get region | str trim
  } else {
    $env.AWS_REGION
  }

  let profile = if ($env.AWS_PROFILE? | is-empty) {
    "default"
  } else {
    $env.AWS_PROFILE
  }

  print $"\nCurrent Region: ($region)"
  print $"Current Profile: ($profile)"
}

# Switch AWS profile with fuzzy search (requires fzf)
export def awsp-select [] {
  if (which fzf | is-empty) {
    print "Error: fzf is required for this function"
    print "Available profiles:"
    aws configure list-profiles
    return
  }

  let profile = (aws configure list-profiles | fzf --height 40% --reverse | str trim)

  if ($profile | is-empty) {
    return
  }

  $env.AWS_PROFILE = $profile
  print $"Switched to AWS profile: ($profile)"
  aws-whoami
}

# Set AWS profile
export def awsp [profile: string] {
  $env.AWS_PROFILE = $profile
  print $"AWS_PROFILE set to: ($profile)"
  aws-whoami
}

# Get EC2 instance ID by name tag
export def ec2-id [name_tag: string] {
  aws ec2 describe-instances --filters $"Name=tag:Name,Values=*($name_tag)*" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].[InstanceId,Tags[?Key=='Name'].Value|[0]]" --output table
}

# SSH into EC2 instance by name
export def ec2-ssh [
  name_tag: string
  --user(-u): string = "ec2-user"  # SSH user (default: ec2-user)
] {
  let ip = (
    aws ec2 describe-instances
      --filters $"Name=tag:Name,Values=*($name_tag)*" "Name=instance-state-name,Values=running"
      --query "Reservations[0].Instances[0].PublicIpAddress"
      --output text
    | str trim
  )

  if ($ip == "None" or ($ip | is-empty)) {
    print $"No running instance found with name: ($name_tag)"
    return
  }

  print $"Connecting to ($ip) as ($user)"
  ssh $"($user)@($ip)"
}

# SSM connect to EC2 instance by name
export def ec2-ssm [name_tag: string] {
  let instance_id = (
    aws ec2 describe-instances
      --filters $"Name=tag:Name,Values=*($name_tag)*" "Name=instance-state-name,Values=running"
      --query "Reservations[0].Instances[0].InstanceId"
      --output text
    | str trim
  )

  if ($instance_id == "None" or ($instance_id | is-empty)) {
    print $"No running instance found with name: ($name_tag)"
    return
  }

  print $"Connecting to instance: ($instance_id)"
  aws ssm start-session --target $instance_id
}

# Update EKS kubeconfig by cluster name pattern
export def eks-use [cluster_name: string] {
  let clusters = (aws eks list-clusters --output text --query 'clusters[]' | str trim | split row "\t")

  let cluster = ($clusters | where { |it| $it =~ $"(?i)($cluster_name)" } | first)

  if ($cluster | is-empty) {
    print $"No cluster found matching: ($cluster_name)"
    print "\nAvailable clusters:"
    aws eks list-clusters --output table
    return
  }

  print $"Updating kubeconfig for cluster: ($cluster)"
  aws eks update-kubeconfig --name $cluster
}

# Get CloudWatch logs for Lambda function
export def lambda-logs [
  function_name: string
  --minutes(-m): int = 60  # Minutes ago to start tailing (default: 60)
] {
  let log_group = $"/aws/lambda/($function_name)"
  let mins = $minutes
  print $"Tailing logs for ($log_group) \(last ($mins) minutes)..."
  aws logs tail $log_group --since $"($mins)m" --follow
}

# Empty S3 bucket (be careful!)
export def s3-empty [bucket_name: string] {
  print $"WARNING: This will delete all objects in s3://($bucket_name)"
  let response = (input "Are you sure? (yes/no): ")

  if ($response == "yes") {
    aws s3 rm $"s3://($bucket_name)" --recursive
    print $"Bucket emptied: ($bucket_name)"
  } else {
    print "Aborted"
  }
}

# List all AWS regions
export def aws-regions [] {
  aws ec2 describe-regions --query "Regions[].[RegionName]" --output text | str trim | split row "\n" | sort
}

# Switch AWS region
export def aws-region [region?: string] {
  if ($region | is-empty) {
    let current_region = if ($env.AWS_REGION? | is-empty) {
      aws configure get region | str trim
    } else {
      $env.AWS_REGION
    }

    print $"Current region: ($current_region)"
    print "\nAvailable regions:"
    aws-regions
    return
  }

  $env.AWS_REGION = $region
  print $"Switched to region: ($region)"
}

# Get parameter store values by path
export def ssm-get-path [path: string] {
  aws ssm get-parameters-by-path --path $path --recursive --with-decryption --query "Parameters[].[Name,Value]" --output table
}

# Get today's AWS costs
export def aws-cost-today [] {
  let start_date = (date now | format date "%Y-%m-01")
  let end_date = (date now | format date "%Y-%m-%d")

  aws ce get-cost-and-usage --time-period $"Start=($start_date),End=($end_date)" --granularity MONTHLY --metrics BlendingCost
}

# List EC2 instances as structured data
export def ec2-list [] {
  aws ec2 describe-instances --output json | from json | get Reservations | flatten | get Instances | flatten
}

# Get EC2 instance details by ID
export def ec2-get [instance_id: string] {
  aws ec2 describe-instances --instance-ids $instance_id --output json | from json | get Reservations | flatten | get Instances | first
}

# List S3 buckets as structured data
export def s3-list-buckets [] {
  aws s3api list-buckets --output json | from json | get Buckets
}

# Get S3 bucket size
export def s3-bucket-size [bucket: string] {
  aws s3 ls $"s3://($bucket)" --recursive --summarize --human-readable | lines | last 2
}

# List Lambda functions as structured data
export def lambda-list [] {
  aws lambda list-functions --output json | from json | get Functions
}

# Get Lambda function configuration
export def lambda-get [function_name: string] {
  aws lambda get-function --function-name $function_name --output json | from json
}

# List IAM users as structured data
export def iam-list-users [] {
  aws iam list-users --output json | from json | get Users
}

# List IAM roles as structured data
export def iam-list-roles [] {
  aws iam list-roles --output json | from json | get Roles
}

# Get current caller identity as structured data
export def aws-identity [] {
  aws sts get-caller-identity --output json | from json
}

# List RDS instances as structured data
export def rds-list [] {
  aws rds describe-db-instances --output json | from json | get DBInstances
}

# List VPCs as structured data
export def vpc-list [] {
  aws ec2 describe-vpcs --output json | from json | get Vpcs
}

# List security groups as structured data
export def sg-list [] {
  aws ec2 describe-security-groups --output json | from json | get SecurityGroups
}

# List EKS clusters as structured data
export def eks-list [] {
  let cluster_names = (aws eks list-clusters --output json | from json | get clusters)
  $cluster_names | each { |name|
    aws eks describe-cluster --name $name --output json | from json | get cluster
  }
}

# Get EKS cluster details
export def eks-get [cluster_name: string] {
  aws eks describe-cluster --name $cluster_name --output json | from json | get cluster
}

# List CloudFormation stacks as structured data
export def cf-list-stacks [] {
  aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE --output json | from json | get StackSummaries
}

# Get CloudFormation stack details
export def cf-get-stack [stack_name: string] {
  aws cloudformation describe-stacks --stack-name $stack_name --output json | from json | get Stacks | first
}

# List Secrets Manager secrets as structured data
export def secrets-list [] {
  aws secretsmanager list-secrets --output json | from json | get SecretList
}

# Get secret value as structured data
export def secrets-get-value [secret_id: string] {
  aws secretsmanager get-secret-value --secret-id $secret_id --output json | from json
}

# List SSM parameters as structured data
export def ssm-list-params [] {
  aws ssm describe-parameters --output json | from json | get Parameters
}

# Get SSM parameter value
export def ssm-get-value [
  name: string
  --decrypt(-d)  # Decrypt SecureString parameters
] {
  if $decrypt {
    aws ssm get-parameter --name $name --with-decryption --output json | from json | get Parameter
  } else {
    aws ssm get-parameter --name $name --output json | from json | get Parameter
  }
}

# List CloudWatch log groups as structured data
export def logs-list-groups [] {
  aws logs describe-log-groups --output json | from json | get logGroups
}

# Search EC2 instances by tag
export def ec2-find-by-tag [
  key: string
  value: string
] {
  aws ec2 describe-instances --filters $"Name=tag:($key),Values=*($value)*" --output json | from json | get Reservations | flatten | get Instances | flatten
}

# Get all tags for a resource
export def aws-get-tags [resource_arn: string] {
  aws resourcegroupstaggingapi get-resources --resource-arn-list $resource_arn --output json | from json | get ResourceTagMappingList | first | get Tags
}

# List all resources with a specific tag
export def aws-find-by-tag [
  key: string
  value: string
] {
  aws resourcegroupstaggingapi get-resources --tag-filters $"Key=($key),Values=($value)" --output json | from json | get ResourceTagMappingList
}

# AWS profile manager with structured output
export def aws-profiles [] {
  aws configure list-profiles | lines | each { |profile|
    {
      profile: $profile
      is_current: ($env.AWS_PROFILE? == $profile)
    }
  }
}

# Get AWS account ID
export def aws-account-id [] {
  aws sts get-caller-identity --query Account --output text | str trim
}

# Get AWS account alias
export def aws-account-alias [] {
  aws iam list-account-aliases --output json | from json | get AccountAliases | first
}

# Quick switch between aws-vault profiles
export def av-exec [
  profile: string
  ...command: string  # Command to execute with the profile
] {
  if ($command | is-empty) {
    aws-vault exec $profile
  } else {
    aws-vault exec $profile -- ...$command
  }
}

# List all AWS services enabled in current region
export def aws-services [] {
  aws service-quotas list-services --output json | from json | get Services
}

# Get EC2 instance console output
export def ec2-console-output [instance_id: string] {
  aws ec2 get-console-output --instance-id $instance_id --output json | from json | get Output
}

# Create EC2 key pair and save to file
export def ec2-create-keypair [
  key_name: string
  --output-file(-o): string = ""  # Output file path (default: ~/.ssh/<key_name>.pem)
] {
  let file_path = if ($output_file | is-empty) {
    $"($env.HOME)/.ssh/($key_name).pem"
  } else {
    $output_file
  }

  aws ec2 create-key-pair --key-name $key_name --query 'KeyMaterial' --output text | save -f $file_path
  chmod 600 $file_path
  print $"Key pair created and saved to: ($file_path)"
}

# List EC2 key pairs
export def ec2-keypairs [] {
  aws ec2 describe-key-pairs --output json | from json | get KeyPairs
}

# Get AWS cost by service for current month
export def aws-cost-by-service [] {
  let start_date = (date now | format date "%Y-%m-01")
  let end_date = (date now | format date "%Y-%m-%d")

  aws ce get-cost-and-usage --time-period $"Start=($start_date),End=($end_date)" --granularity MONTHLY --metrics BlendedCost --group-by Type=DIMENSION,Key=SERVICE --output json | from json
}

# Get AWS cost forecast
export def aws-cost-forecast [
  --months(-m): int = 1  # Number of months to forecast (default: 1)
] {
  let start_date = (date now | format date "%Y-%m-%d")
  let end_date = (date now | into int | $in + ($months * 30 * 86400) | into datetime | format date "%Y-%m-%d")

  aws ce get-cost-forecast --time-period $"Start=($start_date),End=($end_date)" --metric BLENDED_COST --granularity MONTHLY --output json | from json
}
