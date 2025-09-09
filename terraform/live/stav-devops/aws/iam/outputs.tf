output "kubernetes_master_policies" {
  value = [local.ssm_policy]
}

output "kubernetes_nodes_policies" {
  value = [
    local.ssm_policy,
    aws_iam_policy.load_balancer_controller_policy.arn,
    aws_iam_policy.external_dns_policy.arn
  ]
}

output "aws_load_balancer_controller_policy" {
  value = aws_iam_policy.load_balancer_controller_policy.arn
}

output "external_dns_policy" {
  value = aws_iam_policy.external_dns_policy.arn
}

output "kubernetes_karpenter_policy" {
  value = aws_iam_policy.kubernetes_karpenter_policy.arn
}

output "ack_iam_controller_policy" {
  value = aws_iam_policy.ack_controller_management_iam_policy.arn
}

output "ack_s3_controller_policy" {
  value = aws_iam_policy.ack_controller_s3_policy.arn
}