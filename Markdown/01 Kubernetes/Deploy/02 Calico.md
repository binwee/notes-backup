版本3.27.4
```
wget https://raw.githubusercontent.com/projectcalico/calico/v3.27.4/manifests/calico.yaml

```

```
vim calico.yaml
## 可将配置文件中的镜像前缀都替换成 m.daocloud.io/docker.io/calico...
...
            - name: CALICO_IPV4POOL_IPIP
              value: "Never"
            - name: CALICO_IPV4POOL_CIDR
              value: "10.203.0.0/16"
            - name: IP_AUTODETECTION_METHOD
              value: interface=eth0
...
```

```
kubectl create -f calico.yaml
```