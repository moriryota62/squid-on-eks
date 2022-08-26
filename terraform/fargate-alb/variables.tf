# common parameter
variable "base_name" {
  description = "作成するリソースに付与する接頭語"
  type        = string
}

variable "app_name" {
  description = "対象アプリ名"
  type        = string
}

# module parameter
variable "vpc_id" {
  description = "SGを作成するVPCのID"
  type        = string
}

variable "private_subnet_ids" {
  description = "fargateが所属するプライベートサブネットのID"
  type        = list(string)
}

variable "namespace" {
  description = "fargateを使用できるNamespace"
  type        = string
}

variable "labels" {
  description = "fargateを使用できるPodのラベル"
  type        = map(string)
}