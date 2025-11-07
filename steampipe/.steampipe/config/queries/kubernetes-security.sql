-- ╔══════════════════════════════════════════════════════════════╗
-- ║ Kubernetes Security Audit Queries                           ║
-- ╚══════════════════════════════════════════════════════════════╝
--
-- Security checks for Kubernetes clusters
-- Run with: steampipe query ~/.steampipe/config/queries/kubernetes-security.sql

-- Pods running as root
-- Run: steampipe query "select * from k8s_pods_as_root"
select
  name,
  namespace,
  jsonb_array_elements(pod_spec -> 'containers') ->> 'name' as container_name,
  (jsonb_array_elements(pod_spec -> 'containers') -> 'securityContext' ->> 'runAsUser')::int as run_as_user
from
  kubernetes_pod
where
  (jsonb_array_elements(pod_spec -> 'containers') -> 'securityContext' ->> 'runAsUser')::int = 0
  or (pod_spec -> 'securityContext' ->> 'runAsUser')::int = 0
order by
  namespace,
  name;

-- Pods with privileged containers
-- Run: steampipe query "select * from k8s_privileged_pods"
select
  name,
  namespace,
  jsonb_array_elements(pod_spec -> 'containers') ->> 'name' as container_name,
  jsonb_array_elements(pod_spec -> 'containers') -> 'securityContext' ->> 'privileged' as privileged
from
  kubernetes_pod
where
  (jsonb_array_elements(pod_spec -> 'containers') -> 'securityContext' ->> 'privileged')::boolean = true
order by
  namespace,
  name;

-- Pods without resource limits
-- Run: steampipe query "select * from k8s_pods_no_limits"
select
  name,
  namespace,
  jsonb_array_elements(pod_spec -> 'containers') ->> 'name' as container_name,
  jsonb_array_elements(pod_spec -> 'containers') -> 'resources' -> 'limits' as limits
from
  kubernetes_pod
where
  jsonb_array_elements(pod_spec -> 'containers') -> 'resources' -> 'limits' is null
order by
  namespace,
  name;

-- Pods in crashloop or failing
-- Run: steampipe query "select * from k8s_failing_pods"
select
  name,
  namespace,
  phase,
  jsonb_array_elements(container_statuses) ->> 'name' as container_name,
  jsonb_array_elements(container_statuses) -> 'state' as state,
  jsonb_array_elements(container_statuses) ->> 'restartCount' as restart_count
from
  kubernetes_pod
where
  phase in ('Failed', 'Unknown')
  or (jsonb_array_elements(container_statuses) ->> 'restartCount')::int > 5
order by
  (jsonb_array_elements(container_statuses) ->> 'restartCount')::int desc;

-- Services with type LoadBalancer (external exposure)
-- Run: steampipe query "select * from k8s_external_services"
select
  name,
  namespace,
  type,
  cluster_ip,
  external_ips,
  load_balancer_ip
from
  kubernetes_service
where
  type = 'LoadBalancer'
  or external_ips is not null
order by
  namespace,
  name;

-- Namespaces without resource quotas
-- Run: steampipe query "select * from k8s_namespaces_no_quotas"
select
  n.name,
  n.creation_timestamp
from
  kubernetes_namespace as n
  left join kubernetes_resource_quota as rq on n.name = rq.namespace
where
  rq.name is null
  and n.name not in ('kube-system', 'kube-public', 'kube-node-lease', 'default')
order by
  n.name;

-- Service accounts with cluster-admin role
-- Run: steampipe query "select * from k8s_cluster_admins"
select
  rb.name as binding_name,
  rb.namespace,
  sub ->> 'kind' as subject_kind,
  sub ->> 'name' as subject_name,
  sub ->> 'namespace' as subject_namespace
from
  kubernetes_cluster_role_binding as rb,
  jsonb_array_elements(subjects) as sub
where
  role_name = 'cluster-admin'
order by
  subject_name;

-- Secrets older than 1 year
-- Run: steampipe query "select * from k8s_old_secrets"
select
  name,
  namespace,
  type,
  creation_timestamp,
  date_part('day', now() - creation_timestamp) as age_in_days
from
  kubernetes_secret
where
  date_part('day', now() - creation_timestamp) > 365
  and type != 'kubernetes.io/service-account-token'
order by
  age_in_days desc;

-- Pods with host network enabled
-- Run: steampipe query "select * from k8s_host_network_pods"
select
  name,
  namespace,
  host_network,
  host_pid,
  host_ipc
from
  kubernetes_pod
where
  host_network = true
  or host_pid = true
  or host_ipc = true
order by
  namespace,
  name;
