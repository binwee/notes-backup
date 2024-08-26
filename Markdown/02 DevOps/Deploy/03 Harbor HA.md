## 方案说明

共享后端存储算是一种比较标准的方案，多个Harbor实例共享同一个后端存储，任何一个实例持久化到存储的镜像，都可被其他实例中读取。通过前置LB进来的请求，可以分流到不同的实例中去处理，这样就实现了负载均衡，也避免了单点故障。

这个方案在实际生产环境中部署需要考虑三个问题：

1. 共享存储的选取，Harbor的后端存储目前支持AWS S3、Openstack Swift, Ceph等，目前生产环境选择nfs作为后端共享存储。

2. Session在不同的实例上共享，在最新的harbor中，默认session会存放在redis中，只需要将redis独立出来即可。可以通过redis sentinel或者redis cluster等方式来保证redis的可用性，目前生产环境对接外部Redis高可用集群提供给多个harbor使用。

3. Harbor多实例数据库问题，只需要将harbor中的数据库拆出来独立部署即可。让多实例共用一个外部数据库，数据库的高可用也可以通过数据库的高可用方案保证，目前生产环境对接外部postgresql高可用集群提供给多个harbor使用。

### 主机规划

* harbor版本：v2.6.2
* redis版本：5.0
* pgsql版本：13.5
* 存储：nfs
* vip：10.xx.xx.3

#### harbor服务

| role   | ip         | service                                                      |
| ------ | ---------- | ------------------------------------------------------------ |
| master | 10.xx.xx.1 | nginx;harbor-jobservice;harbor-core;registry;registryctl;harbor-portal;harbor-log |
| master | 10.xx.xx.2 | nginx;harbor-jobservice;harbor-core;registry;registryctl;harbor-portal;harbor-log |

#### 外部服务

| ip   | port | service | type       |
| ---- | ---- | ------- | ---------- |
|      | 6483 | redis   | 高可用集群 |
|      | 8090 | pgsql   | 主备集群   |

## 安装Harbor

### 安装docker与docker-compose

略

### 下载Harbor

```shell
wget https://github.com/goharbor/harbor/releases/download/v2.6.2/harbor-offline-installer-v2.6.2.tgz
tar -zxvf harbor-offline-installer-v2.6.2.tgz
cd harbor
cp harbor.yml.tmpl harbor.yml
```

### nfs客户端

```shell
yum -y install nfs-utils
mkdir /data/harbor-data
echo "nfs:/data/harbor-data  /data/harbor-data  nfs defaults 0 0" >>  /etc/fstab
mount -a
```

### 修改配置文件

```shell
vim harbor.yaml
```

```yaml
...
hostname: 10.xx.xx.1	#主机ip
...
#https:					#注释https
 # port: 443
 #certificate: /your/certificate/path
 #private_key: /your/private/key/path
...
```

配置外部存储

```yaml
...
data_volume: /data/harbor-data
...
```

使用外部pgsql，需要手动在外部的PostgreSQL上创建harbor、notary_signer、notary_servers三个数据库，Harbor启动时会自动在对应数据库下生成表。

将配置文件中以下内容取消注释

```yaml
...
external_database:
   harbor:
     host: <pgsqlIp>
     port: 8090
     db_name: harbor
     username: username
     password: password
     ssl_mode: disable
     max_idle_conns: 2
     max_open_conns: 0
   notary_signer:
     host: <pgsqlIp>
     port: 8090
     db_name: notary_signer
     username: username
     password: password
     ssl_mode: disable
   notary_server:
     host: <pgsqlIp>
     port: 8090
     db_name: notary_server
     username: username
     password: password
     ssl_mode: disable
...
```

启用外部redis缓存服务器，将配置文件中以下内容取消注释

```yaml
...
 external_redis:
   host: <redisIp>:6483
   password: password
   registry_db_index: 1
   jobservice_db_index: 2
   chartmuseum_db_index: 3
   trivy_db_index: 5
   idle_timeout_seconds: 30
...
```

### 安装Harbor

```shell
./install.sh
```

测试是否能访问harbor页面

```shell
curl localhost/harbor
```

默认账号admin密码Harbor12345

## 高可用

### 安装HAproxy

```shell
yum install -y haproxy
systemctl start haproxy && systemctl enable haproxy
vim /etc/haproxy/haproxy.cfg
```

```
global
    log         127.0.0.1 local2
    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon
    stats socket /var/lib/haproxy/stats
defaults
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 3000
listen harbor
    bind *:81
    mode tcp
    balance source
    server harbor1 10.xx.xx.1:80 weight 10 check inter 3s fall 3 rise 5
    server harbor2 10.xx.xx.2:80 weight 10 check inter 3s fall 3 rise 5
```

```
systemctl restart haproxy
```

### 安装keepalived

```shell
yum install -y keepalived && yum install -y psmisc
systemctl enable keepalived && systemctl start keepalived
vim /etc/keepalived/keepalived.conf
```

```shell
global_defs {
   router_id LVS_DEVEL
   script_user root
   enable_script_security
}

vrrp_script chk_haproxy {
  script "killall -0 haproxy"
  interval 2
  weight 2
}

vrrp_instance haproxy-vip {
  state BACKUP
  priority 100
  interface eth0
  virtual_router_id 60
  advert_int 1
  authentication {
    auth_type PASS
    auth_pass 1111
  }
  virtual_ipaddress {
    10.xx.xx.3                  # The VIP address
  }

  track_script {
    chk_haproxy
  }
}
```

```shell
systemctl restart keepalived
```