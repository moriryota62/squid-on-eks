# デプロイ手順

## 前提

- terraformでIAMロールを作成済

## デプロイ

- `sa.yaml`のannotationsにあるIAMのARNを修正する。
- マニフェストのapply

``` sh
kubectl apply -f sa.yaml
kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds?ref=master"
helm repo add eks https://aws.github.io/eks-charts
helm repo update
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  --set clusterName=squid \
  --set serviceAccount.create=false \
  --set region=ap-northeast-1 \
  --set vpcId=vpc-06ddf9b90151f0000 \
  --set serviceAccount.name=aws-load-balancer-controller \
  -n kube-system 
```
