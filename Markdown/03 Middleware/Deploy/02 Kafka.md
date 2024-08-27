版本：2.7.2

### 环境依赖

jdk8

集群需提供 zookeeper

### 默认端口

9092 客户端

9308 prometheus监控

### 安装部署

单点部署

```
wget https://archive.apache.org/dist/kafka/2.7.2/kafka_2.13-2.7.2.tgz
tar -zxvf kafka_2.13-2.7.2.tgz
mv kafka_2.13-2.7.2 /usr/local/kafka
# 数据文件
mkdir -p /data/kafka
mkdir -p /data/zookeeper
sed -i "s%dataDir=.*$%dataDir=/data/zookeeper%" /usr/local/kafka/config/zookeeper.properties
sed -i "s%log.dirs=.*$%log.dirs=/data/kafka%" /usr/local/kafka/config/server.properties
# 运行
cd /usr/local/kafka/
bin/zookeeper-server-start.sh -daemon config/zookeeper.properties
bin/kafka-server-start.sh -daemon config/server.properties
```

集群部署

```
wget https://archive.apache.org/dist/kafka/2.7.2/kafka_2.13-2.7.2.tgz
tar -zxvf kafka_2.13-2.7.2.tgz
mv kafka_2.13-2.7.2 /usr/local/kafka
# 数据文件
mkdir -p /data/kafka
sed -i "s%log.dirs=.*$%log.dirs=/data/kafka%" /usr/local/kafka/config/server.properties
```

```
# 逐台修改broker.id，以此类推
sed -i 's/broker.id=0/broker.id=1/' /usr/local/kafka/config/server.properties
sed -i 's/broker.id=0/broker.id=2/' /usr/local/kafka/config/server.properties
sed -i 's/broker.id=0/broker.id=3/' /usr/local/kafka/config/server.properties
```

```
IP=$(hostname -I | awk '{print $1}')
sed -i "s%#listeners=.*$%listeners=PLAINTEXT://$IP:9092%" /usr/local/kafka/config/server.properties
# offset副本数设为3
sed -i 's%offsets.topic.replication.factor=1%offsets.topic.replication.factor=3%' /usr/local/kafka/config/server.properties
# 默认复制因子为3
echo "default.replication.factor=3" >> /usr/local/kafka/config/server.properties
# 配置zookeeper
sed -i "s%zookeeper.connect=.*$%zookeeper.connect=10.xx.xx.1:2181,10.xx.xx.2:2181,10.xx.xx.3:2181/kafka%" /usr/local/kafka/config/server.properties
# 运行
cd /usr/local/kafka/
bin/kafka-server-start.sh -daemon config/server.properties
```

### 监控

```
wget https://github.com/danielqsj/kafka_exporter/releases/download/v1.7.0/kafka_exporter-1.7.0.linux-amd64.tar.gz
tar -zxvf kafka_exporter-1.7.0.linux-amd64.tar.gz
mv kafka_exporter-1.7.0.linux-amd64 /usr/local/kafka_exporter
chown -R root:root /usr/local/kafka_exporter
nohup /usr/local/kafka_exporter/kafka_exporter  --kafka.server=10.xx.xx.1:9092 > /dev/null 2>&1 &
```

### 常用命令

```
cd /usr/local/kafka/
```

后台启动

```bash
bin/kafka-server-start.sh -daemon config/server.properties
```

创建topic

```bash
bin/kafka-topics.sh --bootstrap-server 10.xx.xx.1:9092 --create --topic topicName
```

查看topic列表

```bash
bin/kafka-topics.sh --bootstrap-server 10.xx.xx.1:9092 --list
```

查看topic明细

```bash
bin/kafka-topics.sh --bootstrap-server 10.xx.xx.1:9092 --describe --topic topicName
```

删除topic

```bash
bin/kafka-topics.sh --bootstrap-server 10.xx.xx.1:9092 --delete --topic topicName
```

