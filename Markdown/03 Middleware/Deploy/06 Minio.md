## 默认端口

9000 api

随机 webUi

## 安装部署

单点部署

```
wget https://dl.min.io/server/minio/release/linux-amd64/minio
mv minio /usr/local/bin/
chmod a+x /usr/local/bin/minio
mkdir /data/minio
mkdir /usr/local/minio
```
```
vim /etc/systemd/system/minio.service

[Unit]
Description=MinIO
Documentation=https://docs.min.io
Wants=network-online.target
After=network-online.target
AssertFileIsExecutable=/usr/local/bin/minio

[Service]
EnvironmentFile=/usr/local/minio/env
ExecStart=/usr/local/bin/minio server $MINIO_VOLUMES $MINIO_OPTS
Restart=always
LimitNOFILE=65536
TasksMax=infinity
TimeoutStopSec=infinity
SendSIGKILL=no

[Install]
WantedBy=multi-user.target
```

```
vim /usr/local/minio/env

MINIO_ROOT_USER=admin
MINIO_ROOT_PASSWORD=AAaa00190019!
MINIO_VOLUMES=/data/minio
MINIO_OPTS="--console-address :9001 --address :9000"
```

```
systemctl daemon-reload
systemctl enable --now minio
```


集群部署

minio集群部署需要安装在独占分区，挂载块盘到/minio

```
mkdir -p /minio/data
vim /usr/local/minio/run.sh

#!/bin/bash
export MINIO_ROOT_USER=admin
export MINIO_ROOT_PASSWORD=Admin@1234
export MINIO_PROMETHEUS_AUTH_TYPE=public
nohup /usr/local/bin/minio server \
--address ":9000" \
--console-address ":9001" \
http://10.xx.xx.1/minio/data \
http://10.xx.xx.2/minio/data \
http://10.xx.xx.3/minio/data \
> /dev/null 2>&1 &
```

```
sh /usr/local/minio/run.sh
```

## 监控

```
# /usr/local/minio/run.sh文件中已通过声明环境变量来开启prometheus
export MINIO_PROMETHEUS_AUTH_TYPE=public
```

```
  - job_name: minio
    metrics_path: /minio/v2/metrics/cluster
    static_configs:
    - targets: ["10.xx.xx.1:9000","10.xx.xx.2:9000","10.xx.xx.3:9000"]
```


