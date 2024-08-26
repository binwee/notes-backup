kubectl top 是一个用于查看 Kubernetes 集群中资源使用情况的命令。它可以显示节点或Pod的CPU、内存和存储的使用情况。该命令要求正确配置Metrics Server并在服务器上工作。

部署kube-prometheus后也可以使用kubectl top

```
# 查看集群中所有节点资源使用情况
kubectl top nodes

# 查看集群中某个节点资源使用情况
kubectl top nodes [node name]

# 查询集群中所有Pod资源使用情况(-A 是列举所有命名空间的pod，默认是default名空间)
kubectl top pod -A

# 查询集群中所有Pod资源情况，并安装CPU利用进行排序(sort-by支持两个参数:cpu和memory)
kubectl top pods  -A --sort-by=cpu

# 通过label值查询Pod资源情况
kubectl top pod -l [key]=[value]  -A
```




