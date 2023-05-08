variable "vpc_name" {
    type = string
}

variable "gcp_region" {
  type = string
}

variable "project_name" {
  type = string
}

variable "subnets" {
  type = list(string)

  validation {
    condition = length(var.subnets) == 2
    error_message = "You must provide 2 subnets"
  }
}