
版本2.45.6

## 默认端口

9090 客户端

## 安装部署

```
wget https://github.com/prometheus/prometheus/releases/download/v2.45.6/prometheus-2.45.6.linux-amd64.tar.gz
tar -zxvf prometheus-2.45.6.linux-amd64.tar.gz
mv prometheus-2.45.6.linux-amd64 /usr/local/prometheus
nohup /usr/local/prometheus/prometheus > /dev/null 2>&1 &
```

## Metrics四种类型

- Counter 只增不减的计数器，Counter类型的指标其工作方式和计数器一样，只增不减（除非系统发生重置）。常见的监控指标，如http_requests_total，node_cpu都是Counter类型的监控指标。 一般在定义Counter类型指标的名称时推荐使用_total作为后缀。

总结：`Counter`（计数器）：表示一个单调递增的值，如请求总数、错误总数等。它只能增加，不能减少（除非系统重启）

- Gauge 可增可减的仪表盘，与Counter不同，Gauge类型的指标侧重于反应系统的当前状态。因此这类指标的样本数据可增可减。常见指标如：node_memory_MemFree（主机当前空闲的内容大小）、node_memory_MemAvailable（可用内存大小）都是Gauge类型的监控指标。

总结：`Gauge`（仪表盘）：表示一个可以任意增减的值，如当前内存使用量、CPU 利用率等

- Histograms 意为直方图，Histogram 会在一段时间范围内对数据进行采样（通常是请求持续时间或响应大小等），并将其计入可配置的存储桶（Bucket）中。可以观察到指标在各个不同的区间范围的分布情况，可以观察到请求耗时在各个桶的分布。

总结：`Histogram`（直方图）：表示一组数据的分布情况，如请求延迟的分布。它包含多个 bucket（桶），每个 bucket 对应一个值范围，以及落入该范围的样本数量

- Summary 也是用来做统计分析的，和 Histogram 区别在于，Summary 直接存储的就是百分位数

总结：`Summary`（摘要）：与直方图类似，也表示一组数据的分布情况，但它提供了更精确的分位数（如中位数、95% 分位数等）计算

