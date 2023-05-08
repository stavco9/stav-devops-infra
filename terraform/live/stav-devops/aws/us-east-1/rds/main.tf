module "mysql_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = format("%s-%s-mysql", local.vpc_name, local.db_name)
  description = format("Security group for MYSQL Access to DB %s", local.db_name)
  vpc_id      = data.aws_vpc.project_vpc.id

  ingress_cidr_blocks      = [format("%s/%d", lookup(jsondecode(data.http.my_ip.response_body), "ip", "x.x.x.x") ,32)]
  ingress_rules            = ["mysql-tcp"]

  tags = merge(local.common_tags, {
      Name = format("%s-%s-mysql", local.vpc_name, local.db_name)
  })
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"

  identifier = local.db_name

  engine            = "mysql"
  engine_version    = "8.0.28"
  major_engine_version = "8.0"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name  = local.db_name
  create_random_password = true
  username = "dbadmin"
  port     = "3306"

  iam_database_authentication_enabled = true

  vpc_security_group_ids = [module.mysql_sg.security_group_id]
  availability_zone = data.aws_availability_zones.all_az.names[0]
  multi_az = false
  publicly_accessible = true

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"
  backup_retention_period = 7

  tags = merge(local.common_tags, {
      Name = format("%s-%s-mysql", local.vpc_name, local.db_name)
  })

  # DB subnet group
  create_db_subnet_group = false
  db_subnet_group_name = local.subnet_group

  # DB parameter group
  family = "mysql8.0"
}