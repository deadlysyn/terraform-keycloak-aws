######################################################################
# These are necessary as examples to get started. You could abstract
# these away entirely by providing values as defaults, from other
# modules, as data queries against existing infrastructure, etc.
#
# In practice, I try to keep the number of tunables in the templated
# tfvars as minimal as possible to reduce cognitive load when needing
# to create or adjust environments.
######################################################################

dns_zone_id  = "<Route53 Zone ID>"
vpc_cidr     = "10.20.30.0/24"
public_cidr  = "10.20.30.0/25"
private_cidr = "10.20.30.128/25"

######################################################################
# This section deserves the most attention, though adjustment is not
# strictly necessary. You can scale down to save cost. Scaling up is
# best done by adding more tasks vs bigger tasks.
#
# Note that if running the Datadog sidecar, CPU and memory allocation
# will be auto-adjusted.
######################################################################

alb_certificate_arn = "<GENERATE IN ACM...>"
dns_name            = "<SOMETHING>.sub.domain.tld"
environment         = "%%ENVIRONMENT%%"
region              = "%%REGION%%"

# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#task_size
container_cpu_units                = 1024
container_memory_limit             = 2048
container_memory_reserved          = 1024
jvm_heap_min                       = 512
jvm_heap_max                       = 1024
jvm_meta_min                       = 128
jvm_meta_max                       = 512
deployment_maximum_percent         = 100
deployment_minimum_healthy_percent = 50
desired_count                      = 2 # ECS tasks
log_retention_days                 = 5

# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html
db_instance_type         = "db.r5.large"
db_backup_retention_days = 5
db_cluster_size          = 2

######################################################################
# Ensure unique names for all resources.
######################################################################

namespace = "%%NAMESPACE%%"
