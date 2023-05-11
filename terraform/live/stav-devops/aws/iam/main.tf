locals {
  ecr_pusher_policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
  ecr_pusher_user = "Stav-DevOps-ECR-Pusher"
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