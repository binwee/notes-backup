在一个终端执行

```
kubectl proxy
```

在另一个终端执行，ns-delete替换成要删除的ns

```
curl -H "Content-Type: application/json" -XPUT -d '{"apiVersion":"v1","kind":"Namespace","metadata":{"name":"ns-name"},"spec":{"finalizers":[]}}' http://localhost:8001/api/v1/namespaces/ns-name/finalize
```

