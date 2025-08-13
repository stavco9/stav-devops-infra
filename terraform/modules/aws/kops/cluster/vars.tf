variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "kops_state_bucket" {
  type = string
}

variable "public_key_file_path" {
  type = string
}

variable "dns_zone" {
  type = string
}

variable "kubernetes_version" {
  type = string
  default = "stable"
}

variable "kubernetes_master_policies" {
  type = list(string)
  default = []
}

variable "kubernetes_nodes_policies" {
  type = list(string)
  default = []
}

variable "cluster_admin_iam_roles" {
  type = list(string)
}

variable "ec2_instance_type" {
  type = string
}
variable "master_volume_size" {
  type = number
  default = 15
}

variable "node_volume_size" {
  type = number
  default = 30
}

variable "enable_irsa" {
  type = bool
  default = false
}

variable "enable_aws_load_balancer_controller" {
  type = bool
  default = false
}

variable "enable_karpenter" {
  type = bool
  default = false
}

variable "enable_pod_identity_webhook" {
  type = bool
  default = false
}