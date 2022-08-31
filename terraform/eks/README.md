以下のリソースをデプロイします。

- EKS
- KMS (Secret暗号用)
- IAM (EKS Cluster用)
- CoreDNS関連
  - Fargate Profile
  - IAMロール

terraform.tfvarsは環境にあわせて修正してください。

以下のようなエラーが出る場合、再度terraform applyを実行してください。

```
│ Error: error creating EKS Fargate Profile (mirror-dev:coredns): ResourceNotFoundException: No cluster found for name: mirror-dev.
│ {
│   RespMetadata: {
│     StatusCode: 404,
│     RequestID: "c5fa9659-69d5-4da3-a430-2222844bf151"
│   },
│   Message_: "No cluster found for name: mirror-dev."
│ }
│
│   with aws_eks_fargate_profile.this,
│   on coredns-fargate.tf line 1, in resource "aws_eks_fargate_profile" "this":
│    1: resource "aws_eks_fargate_profile" "this" {
```

FargateのみのEKSクラスタをデプロイします。EC2タイプのワーカーは含みません。

IAM for SAを設定するため`tls_certificate`のデータソースを使用しています。これはProxy配下の環境で実行するとエラーになる可能性があります。エラーになる場合、プロバイダーバージョンを上げるかProxyを経由しない環境でデプロイしてください。参考:[[feature request] Support HTTP proxy for tls_certificate data source](https://github.com/hashicorp/terraform-provider-tls/issues/96)

EKSをデプロイ後、以下のコマンドでkubeconfigを作成できます。

``` sh
aws eks --region ap-northeast-1 update-kubeconfig --name mirror-dev --kubeconfig ~/.kube/config_mirror-test
```

### CoreDNSのFargate起動

CoreDNSをFargateで動かします。EKSデプロイ後、kubeconfigを設定してから以下コマンドでを実行してください。

``` sh
$ kubectl patch deployment coredns \
    -n kube-system \
    --type json \
    -p='[{"op": "remove", "path": "/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type"}]'
```

しばらくするとCoreDNSが以下のようにFargateで動きます。

``` sh
$ kubectl get pod -n kube-system -o wide
NAME                       READY   STATUS    RESTARTS   AGE   IP               NODE                                                    NOMINATED NODE   READINESS GATES
coredns-6c4fc6d4b4-6wwcr   1/1     Running   0          92s   192.168.12.146   fargate-ip-192-168-12-146.ap-south-1.compute.internal   <none>           <none>
coredns-6c4fc6d4b4-wjhf4   1/1     Running   0          92s   192.168.13.168   fargate-ip-192-168-13-168.ap-south-1.compute.internal   <none>           <none>
```