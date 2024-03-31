provider "aws" {
  region = var.region
}

resource "random_string" "namespace" {
  length  = 8
  numeric = false
  special = false
  upper   = false
}

module "terraform_state_backend" {
  source                             = "git::https://github.com/cloudposse/terraform-aws-tfstate-backend.git?ref=tags/1.4.1"
  environment                        = var.environment
  name                               = var.name
  namespace                          = random_string.namespace.result
  tags                               = var.tags
  terraform_backend_config_file_path = "."
  terraform_backend_config_file_name = "backend.tf"
  force_destroy                      = false
}

module "network" {
  count        = var.enable_network ? 1 : 0
  source       = "../../modules/network"
  private_cidr = var.private_cidr
  public_cidr  = var.public_cidr
  tags         = var.tags
  vpc_cidr     = var.vpc_cidr
}

data "aws_subnet" "selected" {
  for_each = var.enable_network ? [] : toset(var.private_subnet_ids)
  id       = each.value
}

locals {
  private_subnet_ids   = var.enable_network ? module.network[0].private_subnet_ids : var.private_subnet_ids
  private_subnet_cidrs = var.enable_network ? module.network[0].private_subnet_cidrs : [for s in data.aws_subnet.selected : s.cidr_block]
  public_subnet_ids    = var.enable_network ? module.network[0].public_subnet_ids : var.public_subnet_ids
  rds_source_region    = var.enable_network ? slice(module.network[0].availability_zones, 0, 1)[0] : var.rds_source_region
  vpc_id               = var.enable_network ? module.network[0].vpc_id : var.vpc_id
}

module "keycloak" {
  source                             = "../../modules/keycloak"
  alb_certificate_arn                = var.alb_certificate_arn
  alb_destroy_log_bucket             = var.alb_destroy_log_bucket
  container_cpu_units                = var.container_cpu_units
  container_memory_limit             = var.container_memory_limit
  container_memory_reserved          = var.container_memory_reserved
  container_port                     = var.container_port
  db_backup_retention_days           = var.db_backup_retention_days
  db_backup_window                   = var.db_backup_window
  db_cluster_family                  = var.db_cluster_family
  db_cluster_size                    = var.db_cluster_size
  db_engine_version                  = var.db_engine_version
  db_instance_type                   = var.db_instance_type
  db_maintenance_window              = var.db_maintenance_window
  deletion_protection                = var.deletion_protection
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  desired_count                      = var.desired_count
  dns_name                           = var.dns_name
  dns_zone_id                        = var.dns_zone_id
  encryption_configuration           = var.encryption_configuration
  environment                        = var.environment
  http_redirect                      = var.http_redirect
  http_ingress_cidr_blocks           = var.http_ingress_cidr_blocks
  https_ingress_cidr_blocks          = var.https_ingress_cidr_blocks
  jvm_heap_min                       = var.jvm_heap_min
  jvm_heap_max                       = var.jvm_heap_max
  jvm_meta_min                       = var.jvm_meta_min
  jvm_meta_max                       = var.jvm_meta_max
  internal                           = var.internal
  log_retention_days                 = var.log_retention_days
  name                               = var.name
  namespace                          = random_string.namespace.result
  private_subnet_ids                 = local.private_subnet_ids
  private_subnet_cidrs               = local.private_subnet_cidrs
  public_subnet_ids                  = local.public_subnet_ids
  rds_source_region                  = local.rds_source_region
  region                             = var.region
  route_table_ids                    = var.route_table_ids
  stickiness                         = var.stickiness
  tags                               = var.tags
  vpc_id                             = local.vpc_id
}
