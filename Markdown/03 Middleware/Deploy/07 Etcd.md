## 部署etcd集群

```
# 所有节点执行
wget https://github.com/etcd-io/etcd/releases/download/v3.5.10/etcd-v3.5.10-linux-amd64.tar.gz
tar -zxvf etcd-v3.5.10-linux-amd64.tar.gz
cd etcd-v3.5.10-linux-amd64
cp -a etcd etcdctl /usr/bin/
mkdir -p /data/etcd
```

```
# 所有节点配置环境变量
export ETCDCTL_API=3
TOKEN=etcd-token
CLUSTER_STATE=new
NAME_1=node1
NAME_2=node2
NAME_3=node3
HOST_1=10.xx.xx.1
HOST_2=10.xx.xx.2
HOST_3=10.xx.xx.3
CLUSTER=${NAME_1}=http://${HOST_1}:2380,${NAME_2}=http://${HOST_2}:2380,${NAME_3}=http://${HOST_3}:2380

# 节点1执行
nohup etcd --data-dir=/data/etcd --name ${NAME_1}\
 --initial-advertise-peer-urls http://${HOST_1}:2380 --listen-peer-urls http://${HOST_1}:2380 \
 --advertise-client-urls http://${HOST_1}:2379 --listen-client-urls http://${HOST_1}:2379 \
 --initial-cluster ${CLUSTER} \
 --initial-cluster-state ${CLUSTER_STATE} --initial-cluster-token ${TOKEN} \
 > /dev/null 2>&1 &
 
# 节点2执行
nohup etcd --data-dir=/data/etcd --name ${NAME_2}\
 --initial-advertise-peer-urls http://${HOST_2}:2380 --listen-peer-urls http://${HOST_2}:2380 \
 --advertise-client-urls http://${HOST_2}:2379 --listen-client-urls http://${HOST_2}:2379 \
 --initial-cluster ${CLUSTER} \
 --initial-cluster-state ${CLUSTER_STATE} --initial-cluster-token ${TOKEN} \
 > /dev/null 2>&1 &
 
# 节点3执行
nohup etcd --data-dir=/data/etcd --name ${NAME_3}\
 --initial-advertise-peer-urls http://${HOST_3}:2380 --listen-peer-urls http://${HOST_3}:2380 \
 --advertise-client-urls http://${HOST_3}:2379 --listen-client-urls http://${HOST_3}:2379 \
 --initial-cluster ${CLUSTER} \
 --initial-cluster-state ${CLUSTER_STATE} --initial-cluster-token ${TOKEN} \
 > /dev/null 2>&1 &
```

```
# 查看etcd集群信息
export ETCDCTL_API=3
HOST_1=10.203.52.133
HOST_2=10.203.52.134
HOST_3=10.203.52.135
etcdctl --endpoints=$HOST_1:2379,$HOST_2:2379,$HOST_3:2379 member list
```


