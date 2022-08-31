base_name = "mirror-dev"
app_name  = "alb-controller"
namespace = "kube-system"
labels    = { "app.kubernetes.io/name" = "aws-load-balancer-controller" }
private_subnet_ids = [
  "subnet-016d6626XXXXXX9e1",
  "subnet-07c7289cXXXXXX117",
]
vpc_id = "vpc-09527bf99XXXXXXXX"
