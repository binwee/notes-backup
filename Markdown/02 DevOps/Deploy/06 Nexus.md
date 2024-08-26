
## 环境依赖

jdk8

## 默认端口

8081

## 安装部署

```
wget https://download.sonatype.com/nexus/3/nexus-3.70.1-02-java8-unix.tar.gz
tar -zxvf nexus-3.70.1-02-java8-unix.tar.gz
mv nexus-3.70.1-02 /usr/local/nexus
mv sonatype-work/ /data/sonatype-work
```

修改配置文件

```
vim /usr/local/nexus/bin/nexus.vmoptions

-XX:LogFile=/data/sonatype-work/nexus3/log/jvm.log
-Dkaraf.data=/data/sonatype-work/nexus3
-Dkaraf.log=/data/sonatype-work/nexus3/log
-Djava.io.tmpdir=/data/sonatype-work/nexus3/tmp
```

```
vim /usr/local/nexus/bin/nexus

run_as_root=false
```

```
# 启动
/usr/local/nexus/bin/nexus start
# 停止
/usr/local/nexus/bin/nexus stop
# 查看admin默认密码
cat /data/sonatype-work/nexus3/admin.password
```

