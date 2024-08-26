## 安装etcdctl

```
wget https://github.com/etcd-io/etcd/releases/download/v3.5.12/etcd-v3.5.12-linux-amd64.tar.gz
tar -zxvf etcd-v3.5.12-linux-amd64.tar.gz
cp etcd-v3.5.12-linux-amd64/etcdctl /usr/local/bin/
```

## 备份

```
ETCDCTL_API=3 etcdctl \
snapshot save /data/etcd-snapshot.db \
--endpoints=https://127.0.0.1:2379 \
--cacert=/etc/kubernetes/pki/etcd/ca.crt \
--cert=/etc/kubernetes/pki/etcd/peer.crt \
--key=/etc/kubernetes/pki/etcd/peer.key
```

## 恢复

```
# 停止apiserver和etcd
mv /etc/kubernetes/manifests /etc/kubernetes/manifests.bak
mv /var/lib/etcd/ /var/lib/etcd.bak
# 恢复
ETCDCTL_API=3 etcdctl snapshot restore /data/etcd-snapshot.db --data-dir=/var/lib/etcd
# 启动apiserver和etcd
mv /etc/kubernetes/manifests.bak /etc/kubernetes/manifests
```


