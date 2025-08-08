variable "environment" {
    type = string
}

variable "project" {
  type = string
}

variable "create_bucket" {
  type = bool
  default = true
}

variable "create_mongodb_cluster" {
  type = bool
  default = true
}

variable "mongodb_iam_roles_access" {
  type = list(string)
  default = []
}