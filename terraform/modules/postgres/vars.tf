variable "env" {
  validation {
    condition     = contains(["DEV", "QA", "PROD", "BACKUP"], var.env)
    error_message = "Env must be DEV QA or PROD."
  }
}

variable "project" {
  type    = string
  default = "owna"
}

variable "db_name" {
  type    = string
  default = "owna"
}

variable "db_version" {
  type    = string
  default = "14"
}

variable "db_user" {
  type    = string
  default = ""
}

variable "db_password" {
  type      = string
  default   = ""
  sensitive = true
}

variable "vpc_id" {
  type = string
}

variable "db_subnet_group" {
  type = string
}

variable "rds_access_cidrs" {
  type = list(string)
}