以下のリソースのマニフェストが含まれます。

- Deployment
- Service
- ConfigMap
  - squid.conf
  - whitelist

ServiceはALB Controllerが前提です。ALB Controllerを先にデプロイでしてください。ServiceをデプロイしてもNLBが作成されない場合、サブネットのタグを確認してみてください。とくにクラスタ名の指定があっているか確認してください。[Amazon EKS でのアプリケーション負荷分散](https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/alb-ingress.html)

PodをFargateで動かす場合、Fargate Profileのセレクターと合わせてください。デフォルトではNamespace:`kube-system`、Lable:`app:squid`を想定しています。

squid.confでは`10.1.0.0/16`(VPC CIDR)からのアクセスを許可する設定をしています。VPC CIDRは環境に合わせて修正してください。

whitelistに許可するドメインを指定します。