variable "alb_certificate_arn" {
  description = "ACM certificate ARN used by ALB"
  type        = string
}

variable "alb_destroy_log_bucket" {
  description = "Destroy ALB log bucket on teardown"
  type        = bool
}

variable "rds_source_region" {
  description = "Region of primary RDS cluster (needed to support encryption)"
  type        = string
}

variable "container_cpu_units" {
  description = "CPU units to reserve for container (1024 units == 1 CPU)"
  type        = number
}

variable "container_memory_limit" {
  description = "Container memory hard limit"
  type        = number
}

variable "container_memory_reserved" {
  description = "Container memory starting reservation"
  type        = number
}

variable "container_port" {
  description = "Keycloak port exposed in container"
  type        = number
}

variable "db_allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to access DB cluster"
  type        = list(string)
  default     = []
}

variable "db_backup_retention_days" {
  description = "How long Database backups are retained"
  type        = number
}

variable "db_backup_window" {
  description = "Daily time range during which backups happen"
  type        = string
}

variable "db_cluster_family" {
  description = "Family of DB cluster parameter group"
  type        = string
}

variable "db_cluster_size" {
  description = "Number of RDS cluster instances"
  type        = number
}

variable "db_engine_version" {
  description = "Version of DB engine to use"
  type        = string
}

variable "db_instance_type" {
  description = "Instance type used for RDS instances"
  type        = string
}

variable "db_maintenance_window" {
  description = "Weekly time range during which system maintenance can occur (UTC)"
  type        = string
}

variable "deletion_protection" {
  description = "Protect resources from being deleted"
  type        = bool
}

variable "deployment_maximum_percent" {
  description = "Maximum task instances allowed to run"
  type        = number
}

variable "deployment_minimum_healthy_percent" {
  description = "Minimum percentage of healthy task instances"
  type        = number
}

variable "desired_count" {
  description = "Number of ECS task instances to run"
  type        = number
}

variable "dns_name" {
  description = "Keycloak FQDN"
  type        = string
}

variable "dns_zone_id" {
  description = "Route53 Zone ID hosting Keycloak FQDN"
  type        = string
}

variable "encryption_configuration" {
  type = object({
    encryption_type = string
    kms_key         = any
  })
  description = "ECR encryption configuration"
}

variable "environment" {
  description = "Environment name (development, production, etc)"
  type        = string
}

variable "http_redirect" {
  description = "Controls whether port 80 should redirect to 443 (or not listen)"
  type        = bool
}

variable "http_ingress_cidr_blocks" {
  description = "CIDR ranges allowed to connect to service port 80"
  type        = list(string)
}

variable "https_ingress_cidr_blocks" {
  description = "CIDR ranges allowed to connect to service port 443"
  type        = list(string)
}

variable "internal" {
  description = "Whether environment should be exposed to Internet (if not using network module)"
  type        = bool
}

variable "jvm_heap_min" {
  description = "Minimum JVM heap size for application in MB"
  type        = number
}

variable "jvm_heap_max" {
  description = "Maximum JVM heap size for application in MB"
  type        = number
}

variable "jvm_meta_min" {
  description = "Minimum JVM meta space size for application in MB"
  type        = number
}

variable "jvm_meta_max" {
  description = "Maximum JVM meta space size for application in MB"
  type        = number
}

variable "log_retention_days" {
  description = "Log retention for CloudWatch logs"
  type        = number
}

variable "name" {
  description = "Used by modules to construct labels"
  type        = string
}

variable "namespace" {
  description = "Used by modules to construct labels"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDR ranges"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "region" {
  description = "AWS region to target"
  type        = string
}

variable "route_table_ids" {
  description = "List of route tables used by s3 VPC endpoint (if not using network module)"
  type        = list(string)
}

variable "stickiness" {
  type = object({
    cookie_duration = number
    enabled         = bool
  })
  description = "Target group sticky configuration"
}

variable "tags" {
  description = "Default tags applied to resources"
  type        = map(string)
}

variable "vpc_id" {
  description = "AWS VPC ID"
  type        = string
}
