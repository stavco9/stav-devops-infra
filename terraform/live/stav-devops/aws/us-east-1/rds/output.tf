output "db_endpoint" {
    value = module.db.db_instance_endpoint
}

output "db_name" {
    value = module.db.db_instance_name 
}

output "db_username" {
    value = nonsensitive(module.db.db_instance_username)
    #sensitive = true
}

output "db_password" {
    value = nonsensitive(module.db.db_instance_password)
    #sensitive = true
}