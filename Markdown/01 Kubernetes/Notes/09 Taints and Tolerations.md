
## 污点
effect类型：
- NoSchedule：表示K8S将不会把Pod调度到具有该污点的Node节点上
- PreferNoSchedule：表示K8S将尽量避免把Pod调度到具有该污点的Node节点上
- NoExecute：表示K8S将不会把Pod调度到具有该污点的Node节点上，同时会将Node上已经存在的Pod驱逐出去

```
# 添加污点
kubectl taint node [node name] key=value:effect
# 删除污点，effect可以不写
kubectl taint node [node name] key[:effect]-
# 查看污点
kubectl describe node [node name] | grep -i taint
```
## 容忍度
```yaml
# key、value、effect要与Node上设置的taint保持一致
tolerations:
- key: "key"
  operator: "Equal"
  value: "value"
  effect: "NoSchedule"

# 当不指定key值和effect值时，且operator为Exists，表示容忍所有的污点
tolerations:
- operator: "Exists"

# 当不指定effect值时，则能匹配污点key对应的所有effects情况
tolerations:
- key: "key"
  operator: "Exists"
```