output "sg_id" {
  value = aws_security_group.postgres_sg.id
}

output "db_address" {
  value = module.postgres-db.db_instance_address
}

output "db_conn_string_secret_name" {
  value = aws_secretsmanager_secret.db_connection_string.name
}

output "db_conn_string_secret_arn" {
  value = aws_secretsmanager_secret.db_connection_string.arn
}