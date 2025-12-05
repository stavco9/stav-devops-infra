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

variable "enable_argocd" {
  type = bool
  default = false
}

variable "enable_prometheus_operator" {
  type = bool
  default = false
}

variable "enable_nginx_ingress_controller" {
  type = bool
  default = false
}

variable "enable_external_dns" {
  type = bool
  default = false
}

variable "enable_aws_secrets_manager_integration" {
  type = bool
  default = false
}

variable "enable_keda" {
  type = bool
  default = false
}

variable "enable_keda_http" {
  type = bool
  default = false
}

variable "custom_apps_iam_roles" {
  type = list(object({
    service_account_name = string
    service_account_namespace = string
    iam_policy_arns = list(string)
  }))
  default = []
}

variable "rabbitmq_operator_version" {
  type = string
  default = "4.4.32"
}

variable "ack_iam_controller_version" {
  type = string
  default = "1.5.0"
}

variable "argocd_version" {
  type = string
  default = "8.3.0"
}

variable "prometheus_operator_version" {
  type = string
  default = "77.5.0"
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

variable "aws_load_balancer_controller_version" {
  type = string
  default = "1.13.4"
}

variable "aws_load_balancer_controller_policy" {
  type = string
  default = ""
}

variable "external_dns_version" {
  type = string
  default = "1.19.0"
}

variable "external_dns_policy" {
  type = string
  default = ""
}

variable "nginx_ingress_controller_version" {
  type = string
  default = "4.13.2"
}

variable "secrets_store_csi_driver_version" {
  type = string
  default = "1.5.3"
}

variable "secrets_store_csi_driver_provider_aws_version" {
  type = string
  default = "2.0.0"
}

variable "keda_version" {
  type = string
  default = "2.18.1"
}

variable "keda_http_version" {
  type = string
  default = "0.11.1"
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
