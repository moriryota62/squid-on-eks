resource "aws_iam_role" "fargate_profile" {
  name = "${var.base_name}-coredns-fargate-profile"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks-fargate-pods.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })

  tags = {
    "Name" = "${var.base_name}-coredns-fargate-profile"
  }
}

resource "aws_iam_policy" "logging" {
  name = "${var.base_name}-coredns-fargate-logging"

  policy = <<EOF
{
    "Version": "2012-10-17",
	"Statement": [{
		"Effect": "Allow",
		"Action": [
			"logs:CreateLogStream",
			"logs:CreateLogGroup",
			"logs:DescribeLogStreams",
			"logs:PutLogEvents"
		],
		"Resource": "*"
	}]
}
EOF
}

resource "aws_iam_role_policy_attachment" "eks_fargate_pod_execution_role" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate_profile.name
}

resource "aws_iam_role_policy_attachment" "eks_fargate_pod_logging_role" {
  policy_arn = aws_iam_policy.logging.arn
  role       = aws_iam_role.fargate_profile.name
}