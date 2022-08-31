# Squid on EKS

セキュリティ対策等でVPCからのアウトバウンドを絞りたい場合があります。最近では[AWS Network Firewall](https://aws.amazon.com/jp/network-firewall/)もありますが、HTTPのHostヘッダやSNIのserver_nameを変えると任意の宛先に出れてしまうようです。そのため、VPCからのアウトバウンドをより厳しく絞りたい場合、VPCにフォワードプロキシを建てます。

VPC内にフォワードプロキシを建てる方法は多々ありますが、EKSのFargateでSquidのフォワードプロキシを建てる方法を解説します。

## Squidとは

> Squid は、HTTP、HTTPS、FTP などをサポートする Web 用のキャッシング プロキシです。頻繁に要求される Web ページをキャッシュして再利用することにより、帯域幅を削減し、応答時間を改善します。Squid には広範なアクセス制御があり、優れたサーバー アクセラレータになります。Windows を含むほとんどの利用可能なオペレーティング システムで実行され、GNU GPL の下でライセンスされています。

出典:[squid-cache.org](http://www.squid-cache.org/)

# 全体像

EKS FargateでSquidのPodを動かします。このPodはVPC内部のNLBで公開します。プロキシを経由してインターネットへ出たいサービスはこのNLBのDNS名をプロキシサーバーとして指定します。Squid PodはNAT Gatewayを経由してインターネットへ出ます。

![全体像](./squid.svg)

# 資材

本レポジトリには以下の資材を含みます。

- Squid Dockerfile
- Terraform
  - eks
  - fargate-alb
  - alb-iam-for-sa
  - fragate-squid
- K8s
  - alb-controller
  - squid

説明や注意事項は各モジュール配下のREDME.mdを確認してください。各terrafomモジュールの`versions.tf`は以下のように設定しています。自身の環境に合わせてタグ等は修正してください。

```
provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      pj    = "mirror"
      env   = "dev"
      owner = "mori"
    }
  }
}
```

# 手順

以下の順で構築します。1~4は任意で実施します。

## 1. EKSデプロイ

EKSデプロイ済の場合は飛ばしてください。

Squidを動かすEKSをデプロイします。[terraform/eks](https://github.com/moriryota62/squid-on-eks/tree/main/terraform/eks)配下のコードでデプロイできます。terraform.tfvarsは環境に合わせて修正してください。

## 2. ALB Controllerデプロイ

ALB Controllerデプロイ済の場合は飛ばしてください。

Squidで内部NLBを使用するためALB Controllerをデプロイします。[terraform/fargate-alb](https://github.com/moriryota62/squid-on-eks/tree/main/terraform/fargate-alb)および[terraform/alb-iam-for-sa](https://github.com/moriryota62/squid-on-eks/tree/main/terraform/alb-iam-for-sa)配下のコードでデプロイできます。terraform.tfvarsは環境に合わせて修正してください。

その後、[k8s/alb-controller](https://github.com/moriryota62/squid-on-eks/tree/main/k8s/alb-controller)配下の手順でALB Controllerをk8sにデプロイしてください。

## 3. Squid用Fargate Profileデプロイ

SquidをFargateで動かすFargate Profileをデプロイします。[terraform/fargate-squid](https://github.com/moriryota62/squid-on-eks/tree/main/terraform/fargate-squid)配下のコードでデプロイしてください。terraform.tfvarsは環境に合わせて修正してください。

## 4. Dockerイメージの準備

SquidのDockerイメージを準備します。すでにビルド済のイメージとして[zakihmkc/squid](https://hub.docker.com/r/zakihmkc/squid)があります。自分でイメージをビルドしたい場合、[image](https://github.com/moriryota62/squid-on-eks/tree/main/image)配下のDockerfileを参考にしてください。

## 5. Squidデプロイ

Squidをデプロイします。[k8s/squid](https://github.com/moriryota62/squid-on-eks/tree/main/k8s/squid)以下のマニフェストをデプロイします。configmapの値は環境に合わせて修正してください。

## 6. 動作確認

1. テスト用にNginxのPodを起動します。

``` sh
$ kubectl run nginx --image=nginx -n kube-system -l app=squid
```

2. NginxのPodに入ります。

``` sh
$ kubectl exec -it nginx -n kube-system -- /bin/sh
```

3. 以下のようにプロキシを指定してcurlを実行します。whitelistで許可したドメインには問題なくアクセスできます。

``` sh
> curl https://www.tis.co.jp -x http://k8s-kubesyst-squid-9805ffda40-3605941818c5eae9.elb.ap-northeast-1.amazonaws.com:3128
```

4. 以下のようにプロキシを指定してcurlを実行します。whitelistで許可していないドメインにはアクセスできません。

``` sh
> curl https://www.google.com -x http://k8s-kubesyst-squid-9805ffda40-3605941818c5eae9.elb.ap-northeast-1.amazonaws.com:3128
```

5. Nginx Podから抜けます。

``` sh
> exit
```

6. 以下コマンドでSquidのログを確認します。上記アクセスした際のログが記録されています。

``` sh
$ kubectl get pod -n kube-system
$ kubectl logs -n kube-system squid-XXXXXXXX
...
2022/08/31 07:12:14| 192.168.13.79 TCP_TUNNEL/200 46966 CONNECT www.tis.co.jp:443 - HIER_DIRECT/163.44.161.163 -
2022/08/31 07:13:05| 192.168.13.79 TCP_DENIED/403 3867 CONNECT www.google.com:443 - HIER_NONE/- text/html
```