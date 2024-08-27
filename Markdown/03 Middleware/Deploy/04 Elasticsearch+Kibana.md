版本：7.17.22

## 环境依赖

自带jdk

## 默认端口

9200 外部通讯

9300 节点之间通讯

9114 prometheus监控

5601 kibana

## 安装部署-ES

单机部署

```sh
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.17.22-x86_64.rpm
yum install -y elasticsearch-7.17.22-x86_64.rpm

# 修改数据目录
mkdir -p /data/elasticsearch
chown -R elasticsearch:elasticsearch /data/elasticsearch
sed -i 's%/var/lib%/data%' /etc/elasticsearch/elasticsearch.yml

# jvm xms与xmx设置为相同值，根据需求与服务器配置，建议4~32g并不超过总内存50%
cat > /etc/elasticsearch/jvm.options.d/heap.options <<EOF
-Xms4g
-Xmx4g
EOF

cat >> /etc/elasticsearch/elasticsearch.yml <<EOF
cluster.name: elasticsearch
node.name: node1
bootstrap.memory_lock: true
network.host: 0.0.0.0
cluster.initial_master_nodes: ["node1"]
http.cors.enabled: true
http.cors.allow-origin: "*"
ingest.geoip.downloader.enabled: false
EOF

systemctl enable --now elasticsearch
```

```
# 检查是否运行成功
curl http://localhost:9200/?pretty
```

集群部署

```
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.17.22-x86_64.rpm
yum install -y elasticsearch-7.17.22-x86_64.rpm

# 修改数据目录
mkdir -p /data/elasticsearch
chown -R elasticsearch:elasticsearch /data/elasticsearch
sed -i 's%/var/lib%/data%' /etc/elasticsearch/elasticsearch.yml

# jvm xms与xmx设置为相同值，根据需求与服务器配置，建议4~32g并不超过总内存50%
cat > /etc/elasticsearch/jvm.options.d/heap.options <<EOF
-Xms4g
-Xmx4g
EOF

cat >> /etc/elasticsearch/elasticsearch.yml <<EOF
cluster.name: elasticsearch-cluster01  # 同集群节点的集群名称相同，不同集群名称不能相同
node.name: node01  # 节点名，同集群不同节点不同，可依次配置node01、node02、node03
bootstrap.memory_lock: true
network.host: 0.0.0.0
discovery.seed_hosts: ["10.xx.xx.1","10.xx.xx.2","10.xx.xx.3"]  # 集群节点ip
cluster.initial_master_nodes: ["node01","node02","node03"] # 集群节点名称
http.cors.enabled: true
http.cors.allow-origin: "*"
ingest.geoip.downloader.enabled: false
EOF

systemctl enable --now elasticsearch
```

```
# 检查集群是否部署成功
curl http://localhost:9200/_cat/health?v
```

## 安装部署-Kibana

```
wget https://artifacts.elastic.co/downloads/kibana/kibana-7.17.22-x86_64.rpm
yum install kibana-7.17.22-x86_64.rpm -y
# 修改配置文件
cat >> /etc/kibana/kibana.yml <<EOF
server.host: "0.0.0.0"
server.publicBaseUrl: "http://10.xx.xx.1:5601"  # 安装kibana的节点IP
elasticsearch.hosts: ["http://10.xx.xx.1:9200","http://10.xx.xx.2:9200","http://10.xx.xx.3:9200"]  # es集群ip
i18n.locale: "zh-CN"
EOF
systemctl enable --now kibana
```

## 监控

```
wget https://github.com/prometheus-community/elasticsearch_exporter/releases/download/v1.7.0/elasticsearch_exporter-1.7.0.linux-amd64.tar.gz
tar -zxvf elasticsearch_exporter-1.7.0.linux-amd64.tar.gz
mv elasticsearch_exporter-1.7.0.linux-amd64 /usr/local/elasticsearch_exporter
chown -R root:root /usr/local/elasticsearch_exporter

nohup /usr/local/elasticsearch_exporter/elasticsearch_exporter --collector.clustersettings --es.all --es.indices --es.indices_settings --es.shards --collector.snapshots > /dev/null 2>&1 &
```


