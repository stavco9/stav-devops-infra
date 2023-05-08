variable "vpc_name"{
    type = string
}

variable "vpc_cidr" {
  type = string
}

variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "private_subnets" {
  type = list(string)

  validation {
    condition = length(var.private_subnets) == 2
    error_message = "You must provide 2 private subnets"
  }
}

variable "enable_nat_gateway" {
  type = bool

  default = true
}

variable "single_nat_gateway" {
  type = bool

  default = true
}

variable "public_subnets" {
  type = list(string)

  validation {
    condition = length(var.public_subnets) == 2
    error_message = "You must provide 2 public subnets"
  }
}