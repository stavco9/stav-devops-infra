locals {
  ecr_pusher_policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
  ssm_policy = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ecr_pusher_user = "Stav-DevOps-ECR-Pusher"
}

data "http" "ack_controller_management_iam_policy" {
  url = "https://raw.githubusercontent.com/aws-controllers-k8s/iam-controller/main/config/iam/recommended-inline-policy"
}

data "http" "ack_controller_s3_policy" {
  url = "https://raw.githubusercontent.com/aws-controllers-k8s/s3-controller/main/config/iam/recommended-inline-policy"
}

resource "aws_iam_user" "ecr_pusher" {
  name = local.ecr_pusher_user
}

resource "aws_iam_access_key" "ecr_pusher" {
  user = aws_iam_user.ecr_pusher.name
}

resource "aws_iam_user_policy_attachment" "ecr_pusher" {
  user = aws_iam_user.ecr_pusher.name
  policy_arn = local.ecr_pusher_policy_arn
}

resource "aws_secretsmanager_secret" "ecr_pusher" {
  name = local.ecr_pusher_user
}

resource "aws_secretsmanager_secret_version" "ecr_pusher" {
  secret_id     = aws_secretsmanager_secret.ecr_pusher.id
  secret_string = jsonencode({
    "AWS_ACCESS_KEY_ID" = aws_iam_access_key.ecr_pusher.id,
    "AWS_SECRET_ACCESS_KEY" = aws_iam_access_key.ecr_pusher.secret
  })
}

resource "aws_iam_policy" "load_balancer_controller_policy" {
  name = "AWSLoadBalancerControllerIAMPolicy"
  policy = file("./aws-load-balancer-permissions.json")
}

resource "aws_iam_policy" "external_dns_policy" {
  name = "AllowExternalDNSUpdates"
  policy = file("./route53-permissions.json")
}

resource "aws_iam_policy" "kubernetes_karpenter_policy" {
  name = "KubernetesKarpenterPolicy"
  policy = file("./karpenter-permissions.json")
}

resource "aws_iam_policy" "ack_controller_management_iam_policy" {
  name = "ACKControllerManagementIAMPolicy"
  policy = data.http.ack_controller_management_iam_policy.response_body
}

resource "aws_iam_policy" "ack_controller_s3_policy" {
  name = "ACKControllerS3Policy"
  policy = data.http.ack_controller_s3_policy.response_body
}