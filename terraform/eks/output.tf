output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "openid_connect_provider_url" {
  value = aws_iam_openid_connect_provider.this.url
}

output "openid_connect_provider_arn" {
  value = aws_iam_openid_connect_provider.this.arn
}

output "eks_certificate_authority" {
  value = aws_eks_cluster.this.certificate_authority.0.data
}

output "eks_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "eks_sg" {
  value = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}