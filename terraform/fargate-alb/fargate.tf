resource "aws_eks_fargate_profile" "this" {
  cluster_name           = var.base_name
  fargate_profile_name   = var.app_name
  pod_execution_role_arn = aws_iam_role.fargate_profile.arn
  subnet_ids             = var.private_subnet_ids

  selector {
    namespace = var.namespace
    labels    = var.labels
  }

  tags = {
    "Name" = var.app_name
  }
}