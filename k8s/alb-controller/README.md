# デプロイ手順

## 前提

- terraformでIAMロールを作成済

## デプロイ

- `sa.yaml`のannotationsにあるIAMのARNを修正する。
- マニフェストのapply　(`clusterName`、`region`、`vpcId`は環境に合わせて変えてください。)

``` sh
kubectl apply -f sa.yaml
kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds?ref=master"
helm repo add eks https://aws.github.io/eks-charts
helm repo update
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  --set clusterName=mirror-dev \
  --set serviceAccount.create=false \
  --set region=ap-northeast-1 \
  --set vpcId=vpc-06ddf9b90151f0000 \
  --set serviceAccount.name=aws-load-balancer-controller \
  -n kube-system 
```

- しばらくすると以下のようにPodが起動します。また、Fargate Profileと合致していればFargateでPodが動きます。

``` sh
$ kubectl get pod -n kube-system -o wide
NAME                                           READY   STATUS    RESTARTS   AGE     IP               NODE                                                    NOMINATED NODE   READINESS GATES
aws-load-balancer-controller-7468df9bb-nw2tg   1/1     Running   0          4m37s   192.168.12.185   fargate-ip-192-168-12-185.ap-south-1.compute.internal   <none>           <none>
aws-load-balancer-controller-7468df9bb-tq6df   1/1     Running   0          4m37s   192.168.13.63    fargate-ip-192-168-13-63.ap-south-1.compute.internal    <none>           <none>
```
