module "label" {
  source      = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.25.0"
  environment = var.environment
  label_order = ["namespace", "name", "environment"]
  name        = var.name
  namespace   = var.namespace
  tags        = var.tags
}

######################################################################
# Note these secrets end up in state. That's why we use encrypted
# remote state by default. This could be refactored to retrieve
# secrets from your vault of choice and inject at runtime.
######################################################################

resource "random_password" "db_password" {
  length  = 30
  special = false
}

resource "random_password" "keycloak_password" {
  length  = 30
  special = false
}

resource "aws_ssm_parameter" "db_password" {
  name        = "/${var.name}/${var.environment}/DB_PASSWORD"
  description = "RDS password for ${module.label.id}"
  tags        = module.label.tags
  type        = "SecureString"
  value       = random_password.db_password.result
}

resource "aws_ssm_parameter" "keycloak_password" {
  name        = "/${var.name}/${var.environment}/KEYCLOAK_PASSWORD"
  description = "keycloak_admin password for ${module.label.id}"
  tags        = module.label.tags
  type        = "SecureString"
  value       = random_password.keycloak_password.result
}

######################################################################
# ALB related resources
######################################################################

module "alb" {
  source                                  = "git::https://github.com/cloudposse/terraform-aws-alb.git?ref=tags/1.11.1"
  alb_access_logs_s3_bucket_force_destroy = var.alb_destroy_log_bucket
  attributes                              = ["alb"]
  certificate_arn                         = var.alb_certificate_arn
  deletion_protection_enabled             = var.deletion_protection
  health_check_interval                   = 60
  health_check_path                       = "/auth/health"
  health_check_timeout                    = 10
  http_ingress_cidr_blocks                = var.http_ingress_cidr_blocks
  http_redirect                           = var.http_redirect
  https_enabled                           = true
  https_ingress_cidr_blocks               = var.https_ingress_cidr_blocks
  internal                                = var.internal
  lifecycle_rule_enabled                  = true
  name                                    = module.label.id
  subnet_ids                              = var.internal ? var.private_subnet_ids : var.public_subnet_ids
  tags                                    = module.label.tags
  target_group_name                       = substr(module.label.id, 0, 31)
  target_group_port                       = var.container_port
  target_group_target_type                = "ip"
  vpc_id                                  = var.vpc_id
  stickiness                              = var.stickiness
}

resource "aws_route53_record" "alb" {
  zone_id = var.dns_zone_id
  name    = var.dns_name
  type    = "A"

  alias {
    name                   = module.alb.alb_dns_name
    zone_id                = module.alb.alb_zone_id
    evaluate_target_health = false
  }
}

######################################################################
# ECS related resources
######################################################################

resource "aws_cloudwatch_log_group" "app" {
  name              = "/aws/ecs/cluster/${module.label.id}"
  retention_in_days = var.log_retention_days
  tags              = module.label.tags
}

resource "aws_ecs_cluster" "keycloak" {
  name = module.label.id
  tags = module.label.tags

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

module "ecr" {
  source                     = "git::https://github.com/cloudposse/terraform-aws-ecr.git?ref=tags/0.41.0"
  encryption_configuration   = var.encryption_configuration
  force_delete               = var.deletion_protection ? false : true
  image_tag_mutability       = "MUTABLE"
  max_image_count            = 3
  name                       = "${var.name}-${var.environment}"
  principals_readonly_access = [module.ecs.task_role_arn]
  scan_images_on_push        = true
  tags                       = module.label.tags
}

resource "aws_vpc_endpoint" "cloudwatch_logs" {
  count               = var.internal ? 1 : 0
  auto_accept         = true
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  service_name        = "com.amazonaws.${var.region}.logs"
  subnet_ids          = var.private_subnet_ids
  tags                = module.label.tags
  vpc_endpoint_type   = "Interface"
  vpc_id              = var.vpc_id
}

resource "aws_vpc_endpoint" "ecr_api" {
  count               = var.internal ? 1 : 0
  auto_accept         = true
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  service_name        = "com.amazonaws.${var.region}.ecr.api"
  subnet_ids          = var.private_subnet_ids
  tags                = module.label.tags
  vpc_endpoint_type   = "Interface"
  vpc_id              = var.vpc_id
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  count               = var.internal ? 1 : 0
  auto_accept         = true
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  service_name        = "com.amazonaws.${var.region}.ecr.dkr"
  subnet_ids          = var.private_subnet_ids
  tags                = module.label.tags
  vpc_endpoint_type   = "Interface"
  vpc_id              = var.vpc_id
}

resource "aws_vpc_endpoint" "s3" {
  count           = var.internal ? 1 : 0
  auto_accept     = true
  route_table_ids = var.route_table_ids
  service_name    = "com.amazonaws.${var.region}.s3"
  tags            = module.label.tags
  vpc_id          = var.vpc_id
}

resource "aws_vpc_endpoint" "ssm" {
  count               = var.internal ? 1 : 0
  auto_accept         = true
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  service_name        = "com.amazonaws.${var.region}.ssm"
  subnet_ids          = var.private_subnet_ids
  tags                = module.label.tags
  vpc_endpoint_type   = "Interface"
  vpc_id              = var.vpc_id
}

resource "aws_vpc_endpoint" "ssm_messages" {
  count               = var.internal ? 1 : 0
  auto_accept         = true
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  service_name        = "com.amazonaws.${var.region}.ssmmessages"
  subnet_ids          = var.private_subnet_ids
  tags                = module.label.tags
  vpc_endpoint_type   = "Interface"
  vpc_id              = var.vpc_id
}

resource "aws_security_group" "vpc_endpoints" {
  name        = "vpc-endpoints"
  description = "Allow traffic for PrivateLink endpoints"
  vpc_id      = var.vpc_id

  ingress {
    description     = "TLS from VPC"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [module.ecs.service_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = module.label.tags
}

data "aws_caller_identity" "current" {}

module "ecs" {
  source = "git::https://github.com/cloudposse/terraform-aws-ecs-alb-service-task.git?ref=tags/0.74.0"
  container_definition_json = templatefile("${path.module}/templates/container_definition.json", {
    aws_account_id            = data.aws_caller_identity.current.account_id
    container_cpu_units       = var.container_cpu_units
    container_memory_limit    = var.container_memory_limit
    container_memory_reserved = var.container_memory_reserved
    db_addr                   = module.rds_cluster.endpoint
    dns_name                  = var.dns_name
    environment               = var.environment
    image                     = "${module.ecr.repository_url}:latest"
    jvm_heap_min              = var.jvm_heap_min
    jvm_heap_max              = var.jvm_heap_max
    jvm_meta_min              = var.jvm_meta_min
    jvm_meta_max              = var.jvm_meta_max
    log_group                 = aws_cloudwatch_log_group.app.name
    name                      = var.name
    region                    = var.region
  })
  alb_security_group                 = module.alb.security_group_id
  attributes                         = ["svc"]
  container_port                     = var.container_port
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  desired_count                      = var.desired_count
  ecs_cluster_arn                    = aws_ecs_cluster.keycloak.arn
  health_check_grace_period_seconds  = 600
  ignore_changes_task_definition     = false
  name                               = module.label.id
  subnet_ids                         = var.private_subnet_ids
  tags                               = module.label.tags
  task_cpu                           = var.container_cpu_units
  task_memory                        = var.container_memory_limit
  use_alb_security_group             = true
  vpc_id                             = var.vpc_id

  ecs_load_balancers = [
    {
      container_name   = var.name
      container_port   = var.container_port
      elb_name         = null # not used with fargate
      target_group_arn = module.alb.default_target_group_arn
    }
  ]
}

resource "aws_security_group_rule" "jdbc_ping" {
  type              = "ingress"
  from_port         = 7800
  to_port           = 7800
  protocol          = "tcp"
  cidr_blocks       = var.private_subnet_cidrs
  security_group_id = module.ecs.service_security_group_id
}

######################################################################
# RDS related resources
######################################################################

module "rds_cluster" {
  source                = "git::https://github.com/cloudposse/terraform-aws-rds-cluster.git?ref=tags/1.9.0"
  admin_password        = random_password.db_password.result
  admin_user            = "keycloak"
  allowed_cidr_blocks   = var.db_allowed_cidr_blocks
  attributes            = ["rds"]
  backup_window         = var.db_backup_window
  cluster_family        = var.db_cluster_family
  cluster_size          = var.db_cluster_size
  copy_tags_to_snapshot = true
  db_name               = "keycloak"
  db_port               = 5432
  deletion_protection   = var.deletion_protection
  engine                = "aurora-postgresql"
  engine_version        = var.db_engine_version
  instance_type         = var.db_instance_type
  maintenance_window    = var.db_maintenance_window
  name                  = module.label.id
  retention_period      = var.db_backup_retention_days
  security_groups       = [module.ecs.service_security_group_id]
  source_region         = var.rds_source_region
  storage_encrypted     = true
  subnets               = var.private_subnet_ids
  tags                  = module.label.tags
  vpc_id                = var.vpc_id
}
