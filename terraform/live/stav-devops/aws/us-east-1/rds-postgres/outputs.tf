output "db_conn_string_secret_name" {
  value = module.rds_postgres.db_conn_string_secret_name
}

output "db_conn_string_secret_arn" {
  value = module.rds_postgres.db_conn_string_secret_arn
}

output "db_conn_string_secret_policy_arn" {
  value = module.rds_postgres.db_conn_string_secret_policy_arn
}

output "db_rds_sg_id" {
  value = module.rds_postgres.sg_id
}