output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "alb_log_bucket" {
  value = module.alb.access_logs_bucket_id
}

output "ecr_repo" {
  value = module.ecr.repository_url
}

output "ecs_cluster" {
  value = aws_ecs_cluster.keycloak.name
}

output "ecs_service" {
  value = module.ecs.service_name
}

output "rds_cluster_endpoint" {
  value = module.rds_cluster.endpoint
}

output "rds_cluster_reader_endpoint" {
  value = module.rds_cluster.reader_endpoint
}

output "rds_cluster_database_name" {
  value = module.rds_cluster.database_name
}

output "rds_cluster_master_username" {
  value = module.rds_cluster.master_username
}
