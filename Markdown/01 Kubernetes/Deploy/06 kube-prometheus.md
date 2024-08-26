版本：0.13.0
```
wget https://codeload.github.com/prometheus-operator/kube-prometheus/tar.gz/refs/tags/v0.13.0
tar -zxvf v0.13.0
cd kube-prometheus-0.13.0
```

```
vim manifests/prometheus-prometheus.yaml
# 末尾添加
...
  retention: 30d
  storage:
    volumeClaimTemplate:
      spec:
        storageClassName: local-path
        resources:
          requests:
            storage: 1Gi
```

```
vim manifests/grafana-deployment.yaml
# 将此处修改为使用pvc
...
      volumes:
      #- emptyDir: {}
      #  name: grafana-storage
      - name: grafana-storage
        persistentVolumeClaim:
          claimName: grafana-data
...
```

```
vim manifests/grafana-pvc.yaml
# 创建grafana pvc
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: grafana-data
  namespace: monitoring
spec:
  storageClassName: managed-nfs-storage
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
```

```
kubectl create -f manifests/setup
kubectl create -f manifests
```

拉不下来的镜像前缀添加 m.daocloud.io/xxx

```
kubectl edit svc prometheus-k8s -n monitoring
kubectl edit svc grafana -n monitoring
# 将prometheus、grafana svc修改为NodePort模式
spec:
...
  # type: ClusterIP
  type: NodePort
...
```
```
# 若其他机器无法访问nodeport，需要删除networkpolicy
kubectl delete networkpolicy --all -n monitoring
```
```
# 删除自带的rule
kubectl delete PrometheusRule --all -A
```


