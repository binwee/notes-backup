版本：1.10.3
```
wget https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.3/deploy/static/provider/cloud/deploy.yaml
```

```
vim deploy.yaml
# 所有镜像前缀可以添加m.daocloud.io/xxx
...
kind: Deployment
...
spec:
  template:
    spec:
      hostNetwork: true  # 使用主机网络
```

```
kubectl create -f deploy.yaml
```

创建ingress的时候需要指定现有的ingressclass。在ingressclass中添加以下配置可以指定为默认的ingressclass。

如果想忽略ingressclass，Deployment中添加以下配置

```
...
    spec:
      containers:
      - args:
        - --ingressclass.kubernetes.io/is-default-class: "true"
...
```

