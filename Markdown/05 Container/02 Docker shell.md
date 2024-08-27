版本：
docker 26.1.4
containerd 1.6.33
docker-compose 2.27.1

```
wget https://download.docker.com/linux/centos/7/x86_64/stable/Packages/containerd.io-1.6.33-3.1.el7.x86_64.rpm
wget https://download.docker.com/linux/centos/7/x86_64/stable/Packages/docker-ce-cli-26.1.4-1.el7.x86_64.rpm
wget https://download.docker.com/linux/centos/7/x86_64/stable/Packages/docker-ce-26.1.4-1.el7.x86_64.rpm
wget https://download.docker.com/linux/centos/7/x86_64/stable/Packages/docker-compose-plugin-2.27.1-1.el7.x86_64.rpm
yum install -y *.rpm
```

```
vim /etc/docker/daemon.json

{
  "log-driver": "json-file",
  "log-opts": {"max-size":"100m", "max-file":"1"},
  "data-root": "/data/docker",
}
```

```
systemctl enable --now docker
```


