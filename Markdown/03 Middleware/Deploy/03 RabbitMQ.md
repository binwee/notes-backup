版本：3.8.30-1

### 环境依赖

erlang>23.2并支持24

```
wget https://github.com/rabbitmq/erlang-rpm/releases/download/v23.3.4.18/erlang-23.3.4.18-1.el7.x86_64.rpm
yum install -y erlang-23.3.4.18-1.el7.x86_64.rpm
```

socat 1.7.3.2-2

```
wget https://mirrors.aliyun.com/centos/7/os/x86_64/Packages/socat-1.7.3.2-2.el7.x86_64.rpm
yum install -y socat-1.7.3.2-2.el7.x86_64.rpm
```

### 默认端口
4369 epmd

5672 AMQP协议端口

15672 管理页面

25672 集群间通信

15692 prometheus监控

### 安装部署

单点部署

```
wget https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.8.30/rabbitmq-server-3.8.30-1.el7.noarch.rpm
yum install -y rabbitmq-server-3.8.30-1.el7.noarch.rpm
```

```
# 数据文件
mkdir -p /data/rabbitmq/data
mkdir -p /data/rabbitmq/logs
chown -R rabbitmq:rabbitmq /data/rabbitmq/
chmod -R 755 /data/rabbitmq/
cat > /etc/rabbitmq/rabbitmq-env.conf <<EOF
RABBITMQ_MNESIA_BASE=/data/rabbitmq/data
RABBITMQ_LOG_BASE=/data/rabbitmq/logs
EOF
```

```
systemctl enable --now rabbitmq-server
```

```
# 安装管理页面
rabbitmq-plugins enable rabbitmq_management
# 创建管理员账号
rabbitmqctl add_user admin admin
rabbitmqctl set_user_tags admin administrator
rabbitmqctl set_permissions -p / admin ".*" ".*" ".*"
# 删除guest账号
rabbitmqctl delete_user guest
```

集群部署

```
# 配置能够寻址到
vim /etc/hosts
```

```
# 集群内/var/lib/rabbitmq/.erlang.cookie保持一致
scp /var/lib/rabbitmq/.erlang.cookie 10.xx.xx.2:/var/lib/rabbitmq/.erlang.cookie
chmod 400 /var/lib/rabbitmq/.erlang.cookie
chown rabbitmq:rabbitmq /var/lib/rabbitmq/.erlang.cookie
```

```
rabbitmqctl stop_app
# 默认节点类型是disc磁盘类型,ram是内存类型
rabbitmqctl join_cluster [--ram] rabbit@主机名
rabbitmqctl start_app
```

```
# 配置镜像队列策略（一台机器上执行）
rabbitmqctl set_policy ha-all "^" '{"ha-mode":"all"}'
```

```
# 修改集群名
rabbitmqctl set_cluster_name rabbit-cluster-name
```

### 监控

```
# 监控插件
rabbitmq-plugins enable rabbitmq_prometheus
```

### 常用命令

查看环境变量

```bash
rabbitmqctl environment
```

用户操作

```bash
# 查看用户
rabbitmqctl list_users
# 创建用户
rabbitmqctl add_user <用户名> <密码>
# e.g.
rabbitmqctl add_user admin p@ssw0rd
# 删除用户
rabbitmqctl delete_user <用户名>
# 修改用户密码
rabbitmqctl change_password <用户名> <密码>
# 清除用户密码
rabbitmqctl clear_password <用户名>
```

权限操作

```bash
# 设置为管理员
rabbitmqctl set_user_tags <用户名> administrator
# 设置用户权限，".*"分别对应vhost中所有资源的配置、写、读权限
rabbitmqctl set_permissions -p / <用户名> ".*" ".*" ".*"
# 查看用户权限
rabbitmqctl list_user_permissions <用户名>
# 查看vhost的用户权限
rabbitmqctl list_permissions [-p <vhost>]
# e.g.
rabbitmqctl list_permissions [-p /]
```

查看集群状态

```bash
rabbitmqctl cluster_status
```

修改集群名

```
rabbitmqctl set_cluster_name rabbit-cluster-name
```

加入集群

```bash
# 需要先停止rabbitmq
rabbitmqctl stop_app
# 重置状态，会清除所有数据
rabbitmqctl reset
# clusternode表示node名称，--ram表示以ram node加入集群
rabbitmqctl join_cluster --ram <clusternode>
# e.g.
rabbitmqctl join_cluster --ram rabbit@rabbitmq01
# 加入后再启动rabbitmq
rabbitmqctl start_app
```

移除节点

```bash
rabbitmqctl forget_cluster_node <clusternode>
# e.g.
rabbitmqctl forget_cluster_node --ram rabbit@rabbitmq02
```

修改节点类型

```bash
rabbitmqctl stop_app
rabbitmqctl change_cluster_node_type disc|ram
rabbitmqctl start_app
```

开启/关闭插件

```bash
rabbitmq-plugins list
rabbitmq-plugins enable rabbitmq_management
rabbitmq-plugins disable rabbitmq_management
```

