以下のリソースのマニフェストが含まれます。

- Deployment
- Service
- ConfigMap
  - squid.conf
  - whitelist

ServiceはALB Controllerが前提です。ALB Controllerを先にデプロイでしてください。ServiceをデプロイしてもNLBが作成されない場合、helmでインストールした時のパラメータやサブネットのタグを確認してみてください。とくにクラスタ名の指定があっているか確認してください。[Amazon EKS でのアプリケーション負荷分散](https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/alb-ingress.html)

デプロイ後、以下コマンドで表示されるEXTERNAL-IPがDNS名です。VPC内からSquidにアクセスするときは以下のDNS名:3128を指定します。

``` sh
$ kubectl get svc -n kube-system
NAME                                TYPE           CLUSTER-IP       EXTERNAL-IP                                                                       PORT(S)          AGE
squid                               LoadBalancer   10.100.206.251   k8s-kubesyst-squid-9805ffda40-3605941818c5eae9.elb.ap-northeast-1.amazonaws.com   3128:30630/TCP   16m
```

PodをFargateで動かす場合、Fargate Profileのセレクターと合わせてください。デフォルトではNamespace:`kube-system`、Lable:`app:squid`を想定しています。

squid.confでは`192.168.0.0/16`(VPC CIDR)からのアクセスを許可する設定をしています。VPC CIDRは環境に合わせて修正してください。

whitelistに許可するドメインを指定します。

## Deployment

SquidのPodを動かすDeploymentです。今回はFargateで動かしたいため、Fargate Profileに合致するようにNamespaceやLabelを指定します。Squidの設定ファイルであるsquid.confと接続先の許可リストであるwhitelistはConfigmapで管理します。それらのファイルを所定のディレクトリ(/etc/squid/)配下に配置するようsubPathをつけてマウントします。

## Service

SquidのデフォルトはTCP:3128で待ち受けるため、TCP:3128を公開します。80および443ポートではないため、ALBではなくNLBでロードバランサーを作成します。[ALB Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller)を使った内部用のNLBをデプロイします。

## Configmap

Configmapは2種類用意します。Squidの設定ファイルであるsquid.confと接続先の許可リストであるwhitelistです。

squid.confは以下のように設定します。設定内容はこちらの[【Squid】プロキシサーバでホワイトリストを作成してアクセス制限をかける](https://chibinfra-techblog.com/proxy-on-aws-ec2-whitelist/)を参考にしました。アクセスを許可している`1192.168.0.0/16`はVPCのCIDRです。環境にあわせて変えてください。Squidのログ出力先を標準出力に変えています。

whitelistは`.amazonaws.com`と`.tis.co.jp`を許可しています。許可するURLを適宜修正してください。
