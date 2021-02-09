# Choose ONE network option, uncomment and customize variables...
#
######################################################################
# Use the included network module to create a self-contained service
# (public ALB, private container instances and DB, with VPC, subnets,
# and everything needed for network connectivity). Simply provide
# the desired network ranges and the module will do the rest.
######################################################################
#
#vpc_cidr     = "10.20.30.0/24"
#public_cidr  = "10.20.30.0/25"
#private_cidr = "10.20.30.128/25"
#
######################################################################
# Or disable the network module and provide required network inputs.
# This is good if you have existing network infrastructure or want a
# private service with no Internet connectivity.
######################################################################
#
#enable_network       = false
#private_subnet_ids   = ["subnet-foo", "subnet-bar"]
#rds_source_region    = "us-east-1a"
#vpc_id               = "vpc-foo"
#
# Either provide public subnet IDs for Internet-facing service...
#public_subnet_ids     = ["subnet-baz", "subnet-qux"]
# Or set internal = true for private service...
#internal              = true

######################################################################
# This section deserves the most attention, though adjustment is not
# strictly necessary. You can scale down to save cost. Scaling up is
# best done by adding more tasks vs bigger tasks.
#
# Note that if running the Datadog sidecar, CPU and memory allocation
# will be auto-adjusted.
######################################################################

alb_certificate_arn = "<Generated in ACM>"
# This is an A record pointing to the ALB...
dns_name            = "<Keycloak service FQDN>"
# ...in this hosted zone:
dns_zone_id         = "<Route53 Zone ID>"
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
