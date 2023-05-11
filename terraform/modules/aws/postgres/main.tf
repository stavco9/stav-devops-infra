locals {
  common_tags = {
    Terraform   = "true"
    Project     = var.project
    Environment = var.env
  }

  conn_str = {
    engine   = module.postgres-db.db_instance_engine
    username = module.postgres-db.db_instance_username
    password = module.postgres-db.db_instance_password
    dbname   = module.postgres-db.db_instance_name
    host     = module.postgres-db.db_instance_address
    port     = module.postgres-db.db_instance_port
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_db_subnet_group" "db_group" {
  name = var.db_subnet_group
}

resource "random_shuffle" "az" {
  input        = slice(data.aws_availability_zones.available.names, 0, length(data.aws_db_subnet_group.db_group.subnet_ids))
  result_count = 1
}

resource "aws_security_group" "postgres_sg" {
  name        = lower("rds-${var.db_name}-${var.env}-sg")
  description = "Allow access to PostgreSQL services"

  vpc_id = var.vpc_id

  tags = merge(local.common_tags, {
    Name = lower("rds-${var.db_name}-${var.env}-sg")
    Type = "RDS"
  })
}

resource "aws_security_group_rule" "postgres_sg_access" {
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = var.rds_access_cidrs
  security_group_id = aws_security_group.postgres_sg.id
}

module "postgres-db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = lower("${var.db_name}-${var.env}")

  engine               = "postgres"
  engine_version       = var.db_version
  family               = "postgres${var.db_version}" # DB parameter group
  major_engine_version = var.db_version              # DB option group

  instance_class        = contains(["prod", "backup"], lower(var.env)) ? "db.t3.medium" : "db.t3.small"
  allocated_storage     = 50
  max_allocated_storage = 1000
  storage_type          = "gp2"

  db_name                = var.db_name
  username               = coalesce(var.db_user, var.db_name)
  create_random_password = false
  password               = coalesce([var.db_password, var.db_user, var.db_name]...)

  iam_database_authentication_enabled = true

  auto_minor_version_upgrade = !(contains(["prod", "backup"], lower(var.env)))
  maintenance_window         = "Tue:05:30-Tue:06:00"
  backup_window              = "08:00-08:30"
  backup_retention_period    = 7

  monitoring_interval    = "30"
  monitoring_role_name   = lower("${var.db_name}-${var.env}-enhanced-monitoring")
  create_monitoring_role = true

  # DB subnet group
  multi_az               = lower(var.env) == "prod"
  db_subnet_group_name   = var.db_subnet_group
  availability_zone      = lower(var.env) != "prod" ? random_shuffle.az.result[0] : null
  vpc_security_group_ids = [aws_security_group.postgres_sg.id]

  enabled_cloudwatch_logs_exports        = ["postgresql", "upgrade"]
  create_cloudwatch_log_group            = true
  cloudwatch_log_group_retention_in_days = 7

  # Database Deletion Protection
  deletion_protection = true

  create_db_parameter_group       = true
  parameter_group_name            = lower("${var.db_name}-${var.env}-postgres${var.db_version}")
  parameter_group_use_name_prefix = false
  parameters = [
    {
      name         = "autovacuum"
      value        = 1,
      apply_method = "pending-reboot"
    },
    {
      name         = "client_encoding"
      value        = "utf8",
      apply_method = "pending-reboot"
    },
    {
      name         = "shared_preload_libraries"
      value        = "pg_stat_statements,pg_cron",
      apply_method = "pending-reboot"
    }
  ]

  tags = local.common_tags
}

resource "aws_secretsmanager_secret" "db_connection_string" {
  name                    = lower("rds-${var.db_name}-${var.env}-conn")
  description             = "Connection string for ${var.db_name} application in environment ${var.env}"
  recovery_window_in_days = 0

  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "db_connection_string" {
  secret_id = aws_secretsmanager_secret.db_connection_string.id
  secret_string = jsonencode(merge(
    { "connection_string" : format("postgresql://%s:%s@%s:%s/%s",
      local.conn_str.username,
      local.conn_str.password,
      local.conn_str.host,
      local.conn_str.port,
  local.conn_str.dbname) }, local.conn_str))
}

resource "aws_iam_policy" "db_read_secret_policy" {
  name = lower("rds-${var.db_name}-${var.env}-conn-raed")
  policy = templatefile("${path.module}/read_secret_policy.json.tpl", {
    DB_SECRET_ARN = aws_secretsmanager_secret.db_connection_string.arn
  })
}