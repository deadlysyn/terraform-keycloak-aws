output "alb_dns_name" {
  value = module.keycloak.alb_dns_name
}

output "alb_log_bucket" {
  value = module.keycloak.alb_log_bucket
}

output "ecr_repo" {
  value = module.keycloak.ecr_repo
}

output "ecs_cluster" {
  value = module.keycloak.ecs_cluster
}

output "ecs_service" {
  value = module.keycloak.ecs_service
}

output "public_subnet_cidrs" {
  value = var.enable_network ? module.network[0].public_subnet_cidrs : []
}

output "private_subnet_cidrs" {
  value = var.enable_network ? module.network[0].private_subnet_cidrs : local.private_subnet_cidrs
}

output "rds_cluster_endpoint" {
  value = module.keycloak.rds_cluster_endpoint
}

output "rds_cluster_reader_endpoint" {
  value = module.keycloak.rds_cluster_reader_endpoint
}

output "rds_cluster_database_name" {
  value = module.keycloak.rds_cluster_database_name
}

output "rds_cluster_master_username" {
  value     = module.keycloak.rds_cluster_master_username
  sensitive = true
}

output "state_table" {
  value = module.terraform_state_backend.dynamodb_table_name
}

output "state_bucket" {
  value = module.terraform_state_backend.s3_bucket_domain_name
}
