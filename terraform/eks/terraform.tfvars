base_name               = "squid"
eks_version             = "1.23"
endpoint_private_access = true
endpoint_public_access  = true
public_access_cidrs     = ["192.0.2.10/32"] #Client CIDR
private_subnet_ids = [
  "subnet-016d6626XXXXXX9e1",
  "subnet-07c7289cXXXXXX117",
]
public_subnet_ids = [
  "subnet-0e3352cXXXXXXX6a1",
  "subnet-02bfe00XXXXXXX03d",
]
enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
