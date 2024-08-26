版本1.28.12

## 环境

```
systemctl stop firewalld.service && systemctl disable firewalld.service
sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config && setenforce 0
sed -i '/swap/s/^/#/' /etc/fstab && swapoff -a && sysctl -w vm.swappiness=0
```

## containerd

```
wget https://github.com/containerd/containerd/releases/download/v1.6.31/containerd-1.6.31-linux-amd64.tar.gz
tar Cxzvf /usr/local containerd-1.6.31-linux-amd64.tar.gz
mkdir -p /usr/local/lib/systemd/system/
```

```
vim /usr/local/lib/systemd/system/containerd.service

[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target local-fs.target
[Service]
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/local/bin/containerd
Type=notify
Delegate=yes
KillMode=process
Restart=always
RestartSec=5
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
OOMScoreAdjust=-999
[Install]
WantedBy=multi-user.target
```

```
wget https://github.com/opencontainers/runc/releases/download/v1.1.13/runc.amd64
chmod 755 runc.amd64
mv runc.amd64 /usr/local/bin/runc
```

```
systemctl enable --now containerd
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
mkdir -p /data/containerd
```

```
vim /etc/containerd/config.toml
...
root = "/data/containerd"
...
    sandbox_image = "registry.aliyuncs.com/google_containers/pause:3.6"
...
                SystemdCgroup = true
...
```

```
echo 'export CONTAINER_RUNTIME_ENDPOINT="unix:///run/containerd/containerd.sock"' >> /etc/profile
source /etc/profile
```

```
systemctl restart containerd
```

## kubernetes

```
wget https://mirrors.aliyun.com/kubernetes-new/core/stable/v1.28/rpm/x86_64/cri-tools-1.28.0-150500.1.1.x86_64.rpm
wget https://mirrors.aliyun.com/kubernetes-new/core/stable/v1.28/rpm/x86_64/kubernetes-cni-1.2.0-150500.2.1.x86_64.rpm
wget https://mirrors.aliyun.com/kubernetes-new/core/stable/v1.28/rpm/x86_64/kubeadm-1.28.12-150500.1.1.x86_64.rpm
wget https://mirrors.aliyun.com/kubernetes-new/core/stable/v1.28/rpm/x86_64/kubectl-1.28.12-150500.1.1.x86_64.rpm
wget https://mirrors.aliyun.com/kubernetes-new/core/stable/v1.28/rpm/x86_64/kubelet-1.28.12-150500.1.1.x86_64.rpm
yum install -y *.rpm
systemctl enable --now kubelet
yum install -y bash-completion
kubectl completion bash > /usr/share/bash-completion/completions/kubectl
kubeadm config images pull --kubernetes-version=1.28.12 --image-repository=registry.aliyuncs.com/google_containers
```

```
kubeadm init \
--kubernetes-version=v1.28.12 \
--pod-network-cidr=10.203.0.0/16 \
--apiserver-advertise-address "10.203.52.125" \
--image-repository registry.aliyuncs.com/google_containers \
--upload-certs \
--v=5
# --pod-network-cidr为pod ip，应与cni（如calico）一致
# --apiserver-advertise-address为master ip
```

```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
