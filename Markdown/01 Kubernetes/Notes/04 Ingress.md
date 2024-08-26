
查看ingress class name

```
kubectl get ingressclass
```

```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
  namespace: default
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
    - http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: nginx-service
                port:
                  number: 80
      # host: test.ingress.com
```

nodePort模式 查看ip

```
kubectl get ingress
```

hostNetwork模式 将域名写入/etc/hosts

```
echo "127.0.0.1 test.ingress.com" >> /etc/hosts
```

