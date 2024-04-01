variable "alb_certificate_arn" {
  description = "ACM certificate used by ALB"
  type        = string
}

variable "alb_destroy_log_bucket" {
  description = "Destroy ALB log bucket on teardown"
  type        = bool
  default     = true
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
  default     = 8080
}

variable "db_backup_retention_days" {
  description = "How long Database backups are retained"
  type        = number
}

variable "db_backup_window" {
  description = "Daily time range during which backups happen"
  type        = string
  default     = "00:00-02:00"
}

variable "db_cluster_family" {
  description = "Family of DB cluster parameter group"
  type        = string
  default     = "aurora-postgresql15"
}

variable "db_cluster_size" {
  description = "Number of RDS cluster instances"
  type        = number
}

variable "db_engine_version" {
  description = "Version of DB engine to use"
  type        = string
  default     = "15.4"
}

variable "db_instance_type" {
  description = "Instance type used for RDS instances"
  type        = string
}

variable "db_maintenance_window" {
  description = "Weekly time range during which system maintenance can occur (UTC)"
  type        = string
  default     = "sat:03:00-sat:04:00"
}

variable "deletion_protection" {
  description = "Protect supporting resources from being deleted (ALB, ECR, RDS)"
  type        = bool
  default     = false
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

variable "enable_network" {
  description = "Use network module (disable to pass in your own network resources)"
  type        = bool
  default     = true
}

variable "encryption_configuration" {
  type = object({
    encryption_type = string
    kms_key         = any
  })
  description = "ECR encryption configuration"
  default = {
    encryption_type = "AES256"
    kms_key         = null
  }
}

variable "environment" {
  description = "Environment name (development, production, etc)"
  type        = string
}

variable "http_redirect" {
  description = "Controls whether port 80 should redirect to 443 (or not listen)"
  type        = bool
  default     = true
}

variable "http_ingress_cidr_blocks" {
  description = "CIDR ranges allowed to connect to service port 80"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "https_ingress_cidr_blocks" {
  description = "CIDR ranges allowed to connect to service port 443"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "internal" {
  description = "Whether environment should be exposed to Internet (if not using network module)"
  type        = string
  default     = false
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
  default     = "keycloak"
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for deployment (if not using network module)"
  type        = list(string)
  default     = []
}

variable "private_cidr" {
  description = "RFC1918 CIDR range for private subnets (subset of vpc_cidr)"
  type        = string
  default     = ""
}

variable "public_cidr" {
  description = "RFC1918 CIDR range for public subnets (subset of vpc_cidr)"
  type        = string
  default     = ""
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for deployment (if not using network module)"
  type        = list(string)
  default     = []
}

variable "rds_source_region" {
  description = "Region of primary RDS cluster (needed to support encryption)"
  type        = string
  default     = ""
}

variable "region" {
  description = "AWS region to target"
  type        = string
}

variable "route_table_ids" {
  description = "List of route tables used by s3 VPC endpoint (if not using network module)"
  type        = list(string)
  default     = []
}

variable "stickiness" {
  type = object({
    cookie_duration = number
    enabled         = bool
  })
  description = "Target group sticky configuration"
  default = {
    cookie_duration = null
    enabled         = false
  }
}

variable "tags" {
  description = "Standard tags for all resources"
  type        = map(any)
  default = {
    Description = "Keycloak IdP"
    Service     = "keycloak"
    Managed-by  = "terraform"
  }
}

variable "vpc_cidr" {
  description = "RFC1918 CIDR range for VPC"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "AWS VPC ID (if not using network module)"
  type        = string
  default     = ""
}
