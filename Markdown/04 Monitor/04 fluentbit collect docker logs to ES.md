
```
wget https://packages.fluentbit.io/centos/7/fluent-bit-2.2.3-1.x86_64.rpm
yum install -y fluent-bit-2.2.3-1.x86_64.rpm
systemctl enable --now fluent-bit
cp /etc/fluent-bit/fluent-bit.conf /etc/fluent-bit/fluent-bit.conf.bak
```

```
vim /etc/fluent-bit/fluent-bit.conf

...
[INPUT]
    name   tail
    path   /data/docker/containers/*/*.log
    tag    docker-log
[OUTPUT]
    name   es
    match  docker-log
    host   [ip]
    port   9200
    index  fluentbit
    type   _doc
```

```
systemctl restart fluent-bit
```

