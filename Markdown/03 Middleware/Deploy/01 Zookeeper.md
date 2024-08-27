版本：3.8.4
### 环境依赖
jdk8
### 默认端口
2181 客户端

2888 集群内通信

3888 选举leader

7000 prometheus监控
### 安装部署
单机部署
```
wget https://dlcdn.apache.org/zookeeper/zookeeper-3.8.4/apache-zookeeper-3.8.4-bin.tar.gz
tar -zxvf apache-zookeeper-3.8.4-bin.tar.gz
mv apache-zookeeper-3.8.4-bin /usr/local/zookeeper
# 创建数据目录
mkdir -p /data/zookeeper
cp /usr/local/zookeeper/conf/zoo_sample.cfg /usr/local/zookeeper/conf/zoo.cfg
sed -i "s%dataDir=.*$%dataDir=/data/zookeeper%" /usr/local/zookeeper/conf/zoo.cfg
```
集群部署

```
vim /usr/local/zookeeper/conf/zoo.cfg
# 在末尾添加集群节点ip
server.1=10.xx.xx.1:2888:3888
server.2=10.xx.xx.2:2888:3888
server.3=10.xx.xx.3:2888:3888
```
```
# 创建myid文件，文件内容为该节点对应的server.x的x
# 如10.xx.xx.1节点为server.1，执行
echo 1 > /data/zookeeper/myid
```
### 监控
```
vim /usr/local/zookeeper/conf/zoo.cfg
# 配置如下
metricsProvider.className=org.apache.zookeeper.metrics.prometheus.PrometheusMetricsProvider
metricsProvider.httpHost=0.0.0.0
metricsProvider.httpPort=7000
metricsProvider.exportJvmInfo=true
```
### 常用命令
```
cd /usr/local/zookeeper/bin
# 启动服务
./zkServer.sh start
# 查看状态
./zkServer.sh status
# 停止服务
./zkServer.sh stop
# 重启服务
./zkServer.sh restart

# 客户端
./zkCli.sh -server 127.0.0.1:2181
# 帮助
help
# 查看某个路径下目录列表
ls path
# 创建节点并赋值（-s 代表顺序节点， -e 代表临时节点，临时节点不能再创建子节点）
# acl访问权限相关，默认是 world，相当于全世界都能访问
create [-s] [-e] path data acl
# 修改节点存储的数据
set path data
# 获取节点数据和状态（-s 显示状态，-w 监听）
get [-s] [-w] path
# 查看节点状态
stat path [watch]
# 删除节点
delete path
# 退出
quit
```

