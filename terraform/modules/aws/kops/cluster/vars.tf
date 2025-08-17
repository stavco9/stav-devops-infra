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

variable "enable_ack_controller" {
  type = bool
  default = false
}

variable "enable_rabbitmq_operator" {
  type = bool
  default = false
}

variable "rabbitmq_operator_version" {
  type = string
  default = "4.4.32"
}

variable "ack_iam_controller_version" {
  type = string
  default = "1.5.0"
}

variable "ack_iam_controller_policy" {
  type = string
  default = ""
}

variable "ack_s3_controller_version" {
  type = string
  default = "1.1.0"
}

variable "ack_s3_controller_policy" {
  type = string
  default = ""
}

variable "turn_off_cluster_at_night" {
  type = bool
  default = false
}

variable "turn_off_cluster_at_night_time_zone" {
  type = string
  default = "UTC"
}

variable "turn_off_master_at_night_recurrence" {
  type = string
  default = ""
}

variable "turn_off_nodes_at_night_recurrence" {
  type = string
  default = ""
}
