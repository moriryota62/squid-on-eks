resource "aws_eks_fargate_profile" "this" {
  cluster_name           = var.base_name
  fargate_profile_name   = "coredns"
  pod_execution_role_arn = aws_iam_role.fargate_profile.arn
  subnet_ids             = var.private_subnet_ids

  selector {
    namespace = "kube-system"
    labels    = { "k8s-app" = "kube-dns" }
  }

  tags = {
    "Name" = "coredns"
  }
}