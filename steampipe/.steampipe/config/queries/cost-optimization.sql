-- ╔══════════════════════════════════════════════════════════════╗
-- ║ Cloud Cost Optimization Queries                             ║
-- ╚══════════════════════════════════════════════════════════════╝
--
-- Find opportunities to reduce cloud costs
-- Run with: steampipe query ~/.steampipe/config/queries/cost-optimization.sql

-- ============================================================
-- AWS Cost Optimization
-- ============================================================

-- Unattached EBS volumes (potential waste)
-- Run: steampipe query "select * from aws_unattached_volumes"
select
  volume_id,
  region,
  size as size_gb,
  volume_type,
  state,
  create_time,
  date_part('day', now() - create_time) as age_in_days
from
  aws_ebs_volume
where
  state = 'available'
order by
  size desc;

-- Idle load balancers (no targets)
-- Run: steampipe query "select * from aws_idle_load_balancers"
select
  load_balancer_name,
  load_balancer_arn,
  region,
  type,
  created_time
from
  aws_ec2_application_load_balancer
where
  target_health_descriptions is null
  or jsonb_array_length(target_health_descriptions) = 0
order by
  load_balancer_name;

-- Old EBS snapshots (older than 90 days)
-- Run: steampipe query "select * from aws_old_snapshots"
select
  snapshot_id,
  volume_id,
  region,
  volume_size,
  start_time,
  date_part('day', now() - start_time) as age_in_days,
  description
from
  aws_ebs_snapshot
where
  date_part('day', now() - start_time) > 90
  and owner_id = (select account_id from aws_account)
order by
  age_in_days desc;

-- Stopped EC2 instances (still incurring EBS costs)
-- Run: steampipe query "select * from aws_stopped_instances"
select
  instance_id,
  instance_type,
  region,
  instance_state,
  state_transition_time,
  date_part('day', now() - state_transition_time) as stopped_days,
  tags ->> 'Name' as name
from
  aws_ec2_instance
where
  instance_state = 'stopped'
  and date_part('day', now() - state_transition_time) > 7
order by
  stopped_days desc;

-- Elastic IPs not associated with instances
-- Run: steampipe query "select * from aws_unattached_eips"
select
  public_ip,
  allocation_id,
  region,
  association_id,
  instance_id,
  network_interface_id
from
  aws_vpc_eip
where
  association_id is null
order by
  region,
  public_ip;

-- RDS instances with low CPU utilization
-- Run: steampipe query "select * from aws_underutilized_rds"
select
  db_instance_identifier,
  db_instance_class,
  engine,
  region,
  multi_az,
  publicly_accessible
from
  aws_rds_db_instance
where
  db_instance_identifier not in (
    select db_instance_identifier
    from aws_rds_db_instance_metric_cpu_utilization_daily
    where average > 20
      and timestamp > current_date - interval '7 days'
  )
order by
  db_instance_identifier;

-- ============================================================
-- Kubernetes Cost Optimization
-- ============================================================

-- Pods with CPU/memory requests much lower than limits
-- Run: steampipe query "select * from k8s_oversized_pods"
select
  name,
  namespace,
  c ->> 'name' as container_name,
  c -> 'resources' -> 'requests' ->> 'cpu' as cpu_request,
  c -> 'resources' -> 'limits' ->> 'cpu' as cpu_limit,
  c -> 'resources' -> 'requests' ->> 'memory' as memory_request,
  c -> 'resources' -> 'limits' ->> 'memory' as memory_limit
from
  kubernetes_pod,
  jsonb_array_elements(pod_spec -> 'containers') as c
where
  c -> 'resources' -> 'limits' is not null
  and c -> 'resources' -> 'requests' is not null
order by
  namespace,
  name;

-- Deployments with only 1 replica (could be right-sized)
-- Run: steampipe query "select * from k8s_single_replica_deployments"
select
  name,
  namespace,
  replicas,
  creation_timestamp
from
  kubernetes_deployment
where
  replicas = 1
order by
  namespace,
  name;

-- Persistent volumes not bound to claims
-- Run: steampipe query "select * from k8s_unbound_pvs"
select
  name,
  capacity_storage,
  storage_class,
  phase,
  creation_timestamp
from
  kubernetes_persistent_volume
where
  phase = 'Available'
order by
  capacity_storage desc;
