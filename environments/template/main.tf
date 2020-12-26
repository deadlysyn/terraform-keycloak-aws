provider "aws" {
  region = var.region
}

module "terraform_state_backend" {
  source                             = "git::https://github.com/cloudposse/terraform-aws-tfstate-backend.git?ref=tags/0.29.0"
  environment                        = var.environment
  name                               = var.name
  namespace                          = var.namespace
  tags                               = var.tags
  terraform_backend_config_file_path = "."
  terraform_backend_config_file_name = "backend.tf"
  force_destroy                      = false
}

module "network" {
  source       = "../../modules/network"
  private_cidr = var.private_cidr
  public_cidr  = var.public_cidr
  tags         = var.tags
  vpc_cidr     = var.vpc_cidr
}

module "keycloak" {
  source                             = "../../modules/keycloak"
  alb_certificate_arn                = var.alb_certificate_arn
  alb_destroy_log_bucket             = var.alb_destroy_log_bucket
  availability_zones                 = module.network.availability_zones
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
  jvm_heap_min                       = var.jvm_heap_min
  jvm_heap_max                       = var.jvm_heap_max
  jvm_meta_min                       = var.jvm_meta_min
  jvm_meta_max                       = var.jvm_meta_max
  log_retention_days                 = var.log_retention_days
  name                               = var.name
  namespace                          = var.namespace
  private_subnet_ids                 = module.network.private_subnet_ids
  private_subnet_cidrs               = module.network.private_subnet_cidrs
  public_subnet_ids                  = module.network.public_subnet_ids
  region                             = var.region
  stickiness                         = var.stickiness
  tags                               = var.tags
  vpc_cidr                           = module.network.vpc_cidr
  vpc_id                             = module.network.vpc_id
}
