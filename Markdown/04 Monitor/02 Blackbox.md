
> 基于blackbox-exporter+prometheus+grafana+alertmanager实现接口探测、数据展示和告警

## 介绍

Blackbox Exporter是一个独立的服务，可以与Prometheus集成，用于探测各种网络服务的可用性和性能。它可以执行HTTP、HTTPS、DNS、TCP等协议的探测，并提供相应的指标，以便Prometheus服务器进行收集和存储。

Blackbox Exporter的工作原理是通过向目标发送请求，并根据响应来判断服务的可用性和性能。它可以配置为定期执行探测，并将结果暴露给Prometheus服务器以供监控和警报。

Prometheus是一个开源的监控和警报工具，广泛用于收集、存储和查询各种应用程序和系统的指标数据。它采用了多维数据模型和灵活的查询语言，可以实时监控服务的状态，并提供丰富的图形化界面和警报机制。

Alertmanager 是一个用于处理和路由警报的组件，它是 Prometheus 生态系统中的一部分。它负责接收来自 Prometheus 服务器的警报，并根据预定义的规则对这些警报进行分类、去重、分组和通知。

Grafana是一个流行的开源数据可视化工具，用于创建丰富、交互式的仪表板，以监控和分析各种指标数据。它支持多种数据源，并提供了强大的查询和可视化功能，使用户能够轻松地理解数据、发现趋势、识别问题，并采取相应的行动。

## 环境准备

Linux Centos 7.9

Docker 20.10.8

## 安装部署

拉取镜像

```shell
$ docker pull prom/blackbox-exporter:latest
$ docker pull prom/prometheus:latest
$ docker pull grafana/grafana-enterprise:latest
$ docker pull prom/alertmanager:latest
```

创建volume

```shell
$ mkdir -m 777 -p /data/{grafana,prometheus/{config,data},blackbox-exporter,alertmanager}
```

创建配置文件

```shell
$ vim /data/prometheus/config/prometheus.yml
global:
  scrape_interval: 15s 
  evaluation_interval: 15s 
alerting:
  alertmanagers:
    - static_configs:
        - targets:
rule_files:
scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]
    
$ vim /data/blackbox-exporter/config.yml
modules:
  http_2xx:
    prober: http
    timeout: 10s
    http:
      valid_http_versions: ["HTTP/1.1", "HTTP/2"]
      valid_status_codes: []
      method: GET
      follow_redirects: true
      fail_if_ssl: false
      fail_if_not_ssl: false
      preferred_ip_protocol: "ip4"
      
$ vim /data/alertmanager/alertmanager.yml
route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'web.hook'
receivers:
- name: 'web.hook'
  webhook_configs:
  - url: 'http://127.0.0.1:5001/'
inhibit_rules:
  - source_match:
      severity: 'critical'
    target_match:
      severity: 'warning'
    equal: ['alertname', 'dev', 'instance']
```

创建容器

```shell
$ docker run -d --name=grafana \
    -p 3000:3000 \
    -v /data/grafana:/var/lib/grafana \
    grafana/grafana-enterprise

$ docker run -d --name=prometheus \
    -p 9090:9090 \
    -v /data/prometheus/config/:/etc/prometheus/ \
    -v /data/prometheus/data:/prometheus/ \
    prom/prometheus

$ docker run -d --name=alertmanager \
    -p 9093:9093 \
    -v /data/alertmanager/:/etc/alertmanager/ \
    prom/alertmanager

$ docker run -d --name=blackbox-exporter \
    -p 9116:9115 \
    -v /data/blackbox-exporter/config.yml:/etc/blackbox_exporter/config.yml \
    prom/blackbox-exporter
```

## 配置blackbox

参数详解（在安装过程中已完成配置该文件）

```shell
$ cat /data/blackbox-exporter/config.yml
modules:                          # 模块配置开始
  http_2xx:                       # HTTP 2xx 探测模块名称
    prober: http                  # 使用 HTTP 探测器
    timeout: 10s                  # 探测超时时间为 10 秒
    http:                         # HTTP 探测器配置开始
      valid_http_versions: ["HTTP/1.1", "HTTP/2"]  # 允许的 HTTP 版本为 HTTP/1.1 和 HTTP/2
      valid_status_codes: []      # 允许的 HTTP 状态码为空，表示默认为 2xx
      method: GET                  # 使用 GET 方法进行请求
      follow_redirects: true      # 跟随重定向
      fail_if_ssl: false          # 如果 SSL 可用，不失败
      fail_if_not_ssl: false      # 如果 SSL 不可用，不失败
      preferred_ip_protocol: "ip4"  # 首选 IP 协议为 IPv4
```

其他参数配置可参考：

[blackbox_exporter/CONFIGURATION.md at master · prometheus/blackbox_exporter (github.com)](https://github.com/prometheus/blackbox_exporter/blob/master/CONFIGURATION.md)

## 配置prometheus

创建job来对网站接口进行探测

```shell
$ vim /data/prometheus/config/prometheus.yml
...
  - job_name: 'blackbox-exporter'
    metrics_path: /probe
    params:
      module: [http_2xx]						#此处为blackbox配置的modeles名称
    static_configs:
      - targets: ['http://website1.com']		#要探测的网站接口
        labels:									#标签可以自定义
          name: 'website1'
          instance: 'port_status'
      - targets: ['http://website2.com']		#可以在该job下面填写多个target，探测多个接口
        labels:
          name: 'website2'
          instance: 'port_status'
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: 10.203.xx.xx:9115			#此处为blackbox的ip+端口
```

## 配置alertmanager

先配置prometheus的alertmanager和rule

```shell
$ vim /data/prometheus/config/prometheus.yml
...
alerting:
  alertmanagers:
    - static_configs:
        - targets:
            - 10.203.xx.xx:9093		#alertmanager的ip+端口
rule_files:
  - "rules/*.yml"
...
```

创建rule文件

```shell
$ mkdir -p /data/prometheus/config/rules
$ vim /data/prometheus/config/rules/interface.yml
groups:
- name: blackbox
  rules:
  - alert: InterfaceDown
    expr: probe_success != 1
    for: 1m
    labels:
      severity: 1
    annotations:
      description: "The web interface < {{ $labels.name }} > is DOWN!"
- name: blackbox agent
  rules:
  - alert: AgentDown
    expr: avg(up{job="blackbox-exporter"}) != 1
    for: 1m
    labels:
      severity: 1
    annotations:
      description: "The Blackbox agent is DOWN!"
```

修改alertmanager配置文件，添加邮件告警（以163邮箱为例）

```shell
$ vim /data/alertmanager/alertmanager.yml
global:  # 全局配置
  resolve_timeout: 1m  # 警报解决的超时时间为1分钟
  smtp_from: 'xxx@163.com'  # 发件人邮箱地址
  smtp_smarthost: 'smtp.163.com:25'  # SMTP服务器地址和端口
  smtp_auth_username: 'xxx@163.com'  # SMTP服务器的身份验证用户名
  smtp_auth_password: XXXXXXX  # SMTP服务器的身份验证密码
  smtp_require_tls: false  # 不要求使用TLS加密
  smtp_hello: '163.com'  # 发件人邮箱的域名

route:  # 警报路由配置
  group_by: ['alertname']  # 按警报名称进行分组
  group_wait: 30s  # 每组警报等待30秒
  group_interval: 5m  # 每组警报之间的间隔为5分钟
  repeat_interval: 1h  # 重复发送警报通知的间隔为1小时
  receiver: 'email'  # 指定接收者为'email'

receivers:  # 接收者配置
  - name: 'email'  # 接收者名称为'email'
    email_configs:  # 邮件配置
    - to: 'xxx@xxx.com'  # 收件人邮箱地址
      send_resolved: true  # 发送解决通知，即当警报恢复时发送邮件通知

inhibit_rules:  # 抑制规则配置
  - source_match:  # 源警报匹配条件
      severity: 'critical'  # 严重程度为'critical'
    target_match:  # 目标警报匹配条件
      severity: 'warning'  # 严重程度为'warning'
    equal: ['alertname', 'dev', 'instance']  # 需要匹配的标签，如果匹配成功，则源警报不会触发目标警报

```

## 配置grafana

grafana配置prometheus为数据源后，可自定义大屏页面

## 重启全部服务

```shell
$ docker restart prometheus alertmanager blackbox-exporter grafana
```



