以下のリソースをデプロイします。

- EKS
- KMS (Secret暗号用)
- IAM (EKS Cluster用)
- CoreDNS関連
  - Fargate Profile
  - IAMロール

FargateのみのEKSクラスタをデプロイします。EC2タイプのワーカーは含みません。

IAM for SAを設定するため`tls_certificate`のデータソースを使用しています。これはProxy配下の環境で実行するとエラーになる可能性があります。エラーになる場合、プロバイダーバージョンを上げるかProxyを経由しない環境でデプロイしてください。参考:[[feature request] Support HTTP proxy for tls_certificate data source](https://github.com/hashicorp/terraform-provider-tls/issues/96)