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

output "kubernetes_karpenter_policy" {
  value = aws_iam_policy.kubernetes_karpenter_policy.arn
}