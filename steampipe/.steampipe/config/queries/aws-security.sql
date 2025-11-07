-- ╔══════════════════════════════════════════════════════════════╗
-- ║ AWS Security Audit Queries                                  ║
-- ╚══════════════════════════════════════════════════════════════╝
--
-- Quick security checks for AWS infrastructure
-- Run with: steampipe query ~/.steampipe/config/queries/aws-security.sql

-- IAM users without MFA enabled
-- Run: steampipe query "select * from aws_iam_users_no_mfa"
select
  name as user_name,
  arn,
  create_date,
  password_last_used
from
  aws_iam_user
where
  mfa_enabled = false
  and password_enabled = true
order by
  create_date desc;

-- Public S3 buckets
-- Run: steampipe query "select * from aws_public_s3_buckets"
select
  name as bucket_name,
  region,
  bucket_policy_is_public,
  block_public_acls,
  block_public_policy
from
  aws_s3_bucket
where
  bucket_policy_is_public = true
  or block_public_acls = false
  or block_public_policy = false
order by
  name;

-- Security groups with unrestricted ingress
-- Run: steampipe query "select * from aws_open_security_groups"
select
  group_name,
  group_id,
  vpc_id,
  region,
  ip_permission ->> 'IpProtocol' as protocol,
  ip_permission ->> 'FromPort' as from_port,
  ip_permission ->> 'ToPort' as to_port,
  cidr_ip
from
  aws_vpc_security_group
  cross join jsonb_array_elements(ip_permissions) as ip_permission
  cross join jsonb_array_elements(ip_permission -> 'IpRanges') as ip_range
  cross join jsonb_array_elements_text(ip_range -> 'CidrIp') as cidr_ip
where
  cidr_ip = '0.0.0.0/0'
order by
  group_name;

-- Unencrypted EBS volumes
-- Run: steampipe query "select * from aws_unencrypted_ebs"
select
  volume_id,
  region,
  encrypted,
  size as size_gb,
  volume_type,
  state,
  create_time
from
  aws_ebs_volume
where
  encrypted = false
order by
  size desc;

-- Unencrypted RDS instances
-- Run: steampipe query "select * from aws_unencrypted_rds"
select
  db_instance_identifier,
  engine,
  engine_version,
  region,
  storage_encrypted,
  publicly_accessible,
  multi_az
from
  aws_rds_db_instance
where
  storage_encrypted = false
order by
  db_instance_identifier;

-- IAM access keys older than 90 days
-- Run: steampipe query "select * from aws_old_access_keys"
select
  u.name as user_name,
  ak.access_key_id,
  ak.create_date,
  ak.status,
  date_part('day', now() - ak.create_date) as age_in_days
from
  aws_iam_user as u
  cross join jsonb_array_elements(u.access_keys) as ak
where
  ak ->> 'Status' = 'Active'
  and date_part('day', now() - (ak ->> 'CreateDate')::timestamp) > 90
order by
  age_in_days desc;

-- EC2 instances without termination protection
-- Run: steampipe query "select * from aws_unprotected_ec2"
select
  instance_id,
  instance_type,
  instance_state,
  region,
  disable_api_termination,
  tags ->> 'Name' as name
from
  aws_ec2_instance
where
  disable_api_termination = false
  and instance_state = 'running'
order by
  instance_id;

-- ELB/ALB without access logging
-- Run: steampipe query "select * from aws_elb_no_logging"
select
  load_balancer_name,
  region,
  scheme,
  type,
  access_logs_enabled
from
  aws_ec2_application_load_balancer
where
  access_logs_enabled = false
union all
select
  load_balancer_name,
  region,
  scheme,
  'classic' as type,
  access_logs_enabled
from
  aws_ec2_classic_load_balancer
where
  access_logs_enabled = false
order by
  load_balancer_name;
