-- ╔══════════════════════════════════════════════════════════════╗
-- ║ Multi-Cloud Infrastructure Inventory                        ║
-- ╚══════════════════════════════════════════════════════════════╝
--
-- Get complete view of infrastructure across clouds
-- Run with: steampipe query ~/.steampipe/config/queries/inventory.sql

-- All compute resources across clouds
-- Run: steampipe query "select * from cloud_compute_inventory"
select
  'AWS' as cloud,
  'EC2' as service,
  instance_id as resource_id,
  instance_type as resource_type,
  region,
  instance_state as state,
  tags ->> 'Name' as name
from
  aws_ec2_instance
union all
select
  'GCP' as cloud,
  'Compute Engine' as service,
  name as resource_id,
  machine_type_name as resource_type,
  location as region,
  status as state,
  labels ->> 'name' as name
from
  gcp_compute_instance
order by
  cloud,
  region,
  resource_id;

-- All storage resources across clouds
-- Run: steampipe query "select * from cloud_storage_inventory"
select
  'AWS' as cloud,
  'S3' as service,
  name as bucket_name,
  region,
  creation_date,
  versioning_enabled
from
  aws_s3_bucket
union all
select
  'GCP' as cloud,
  'Cloud Storage' as service,
  name as bucket_name,
  location as region,
  time_created as creation_date,
  versioning_enabled
from
  gcp_storage_bucket
order by
  cloud,
  bucket_name;

-- All databases across clouds
-- Run: steampipe query "select * from cloud_database_inventory"
select
  'AWS' as cloud,
  'RDS' as service,
  db_instance_identifier as db_name,
  engine,
  engine_version,
  region,
  db_instance_status as status,
  multi_az
from
  aws_rds_db_instance
union all
select
  'GCP' as cloud,
  'Cloud SQL' as service,
  name as db_name,
  database_version as engine,
  database_version as engine_version,
  region,
  state as status,
  settings -> 'availabilityType' = '"REGIONAL"' as multi_az
from
  gcp_sql_database_instance
order by
  cloud,
  db_name;

-- All Kubernetes clusters
-- Run: steampipe query "select * from cloud_k8s_clusters"
select
  'AWS' as cloud,
  'EKS' as service,
  name as cluster_name,
  region,
  version,
  status,
  created_at
from
  aws_eks_cluster
union all
select
  'GCP' as cloud,
  'GKE' as service,
  name as cluster_name,
  location as region,
  current_master_version as version,
  status,
  create_time as created_at
from
  gcp_kubernetes_cluster
order by
  cloud,
  cluster_name;

-- All container images
-- Run: steampipe query "select * from container_image_inventory"
select
  'AWS' as cloud,
  'ECR' as service,
  repository_name,
  image_tags,
  image_pushed_at,
  image_size_in_bytes / 1024 / 1024 as size_mb
from
  aws_ecr_image
union all
select
  'Docker Local' as cloud,
  'Docker' as service,
  repo_tags::text as repository_name,
  repo_tags,
  created as image_pushed_at,
  size / 1024 / 1024 as size_mb
from
  docker_image
order by
  cloud,
  repository_name;

-- Resource count summary
-- Run: steampipe query "select * from resource_count_summary"
select
  'EC2 Instances' as resource_type,
  count(*) as count,
  'AWS' as cloud
from
  aws_ec2_instance
union all
select
  'S3 Buckets',
  count(*),
  'AWS'
from
  aws_s3_bucket
union all
select
  'RDS Instances',
  count(*),
  'AWS'
from
  aws_rds_db_instance
union all
select
  'Lambda Functions',
  count(*),
  'AWS'
from
  aws_lambda_function
union all
select
  'EKS Clusters',
  count(*),
  'AWS'
from
  aws_eks_cluster
union all
select
  'GCE Instances',
  count(*),
  'GCP'
from
  gcp_compute_instance
union all
select
  'GCS Buckets',
  count(*),
  'GCP'
from
  gcp_storage_bucket
union all
select
  'Cloud SQL Instances',
  count(*),
  'GCP'
from
  gcp_sql_database_instance
union all
select
  'GKE Clusters',
  count(*),
  'GCP'
from
  gcp_kubernetes_cluster
union all
select
  'K8s Pods',
  count(*),
  'Kubernetes'
from
  kubernetes_pod
union all
select
  'K8s Services',
  count(*),
  'Kubernetes'
from
  kubernetes_service
union all
select
  'K8s Deployments',
  count(*),
  'Kubernetes'
from
  kubernetes_deployment
order by
  cloud,
  resource_type;
