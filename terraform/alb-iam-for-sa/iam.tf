resource "aws_iam_policy" "policy" {
  name        = "${var.base_name}-AlbControllerPolicy"
  description = "alb controller用のポリシー"

  # 以下ファイルパスはterrafrom applyを実行するディレクトリからの相対パスで記載
  policy = file("./iam-policy.json")
}
