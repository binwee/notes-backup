
## 节点亲和性

### 硬性约束

requiredDuringSchedulingIgnoredDuringExecution：硬性约束，表示调度时必须满足的条件。如果没有节点满足这些条件，Pod将无法调度。

nodeSelectorTerms下的多个matchExpressions是OR关系，即满足一个即可。

matchExpressions下的条件是AND关系，即需要同时满足。

operator:

- In：标签的值必须在指定的列表中。

- NotIn：标签的值必须不在指定的列表中。

- Exists：节点上必须存在指定的标签键（不关心值）。

- DoesNotExist：节点上不能存在指定的标签键。

- Gt：标签的值必须大于指定的值（通常用于数值比较）。

- Lt：标签的值必须小于指定的值（通常用于数值比较）。

values：是一个列表，用于指定与 In 或 NotIn 操作符一起使用的值。

```
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms：
      - matchExpressions：
        - key: [key]
          operator: In
          values:
          - [value]
```

### 软性约束

preferredDuringSchedulingIgnoredDuringExecution：软性约束，表示调度时尽量满足的条件。如果没有节点满足条件，Pod仍然可以被调度到其他节点上，但调度器会优先选择满足条件的节点。

weight： 这是一个整数，表示调度器在满足这个条件时的优先级。权重值越大，调度器越倾向于选择满足该条件的节点。范围0~100。

preference：定义了优先选择的节点标签条件，与requiredDuringSchedulingIgnoredDuringExecution的matchExpressions结构相同。

operator、values 同硬性约束。

```
affinity:
  nodeAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 10
        matchExpressions:
        - key: [key]
        operator: In
        values:
        - [value]
```

## Pod亲和性

```
affinity:
  podAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    - labelSelector:
        matchExpressions:
        - key: [key]
          operator: In
          values:
          - [value]
      topologyKey: kubernetes.io/hostname    
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 1
      preference:
        matchExpressions:
        - key: [key]
          operator: In
          values:
          - [value]
      topologyKey: kubernetes.io/hostname    
```

## Pod反亲和性

```
affinity:
  podAntiAffinity: 
```