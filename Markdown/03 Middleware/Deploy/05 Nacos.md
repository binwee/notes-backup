
版本2.3.2

## 环境依赖

jdk8

mysql>5.6.5

```
wget https://repo.mysql.com//mysql84-community-release-el7-1.noarch.rpm
yum install -y mysql84-community-release-el7-1.noarch.rpm
yum install -y mysql-community-server
systemctl enable --now mysqld
# 查看临时密码
grep "temporary password" /var/log/mysqld.log
# 修改密码
mysql -uroot -p
ALTER USER 'root'@'localhost' IDENTIFIED BY 'Root@1234';
use mysql
update user set host = '%' where user = 'root';
flush privileges;
exit
```

## 默认端口

8848 nacos客户端

7848 集群通信

9848 客户端gRPC请求服务端

9849 服务端gRPC请求服务端

## 安装部署

单点部署

```
wget https://github.com/alibaba/nacos/releases/download/2.3.2/nacos-server-2.3.2.tar.gz
tar -zxvf nacos-server-2.3.2.tar.gz
mv nacos /usr/local/nacos
# 初始化数据库
mysql -h10.xx.xx.1 -P3306 -uroot -pRoot@1234 -e "CREATE DATABASE nacos CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
mysql -h10.xx.xx.1 -P3306 -uroot -pRoot@1234 nacos < /usr/local/nacos/conf/mysql-schema.sql
```

```
# 修改配置文件
vim /usr/local/nacos/conf/application.properties

spring.datasource.platform=mysql
db.num=1
db.url.0=jdbc:mysql://10.xx.xx.1:3306/nacos_devtest?characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true
db.user=root
db.password=Root@1234
```

```
/usr/local/nacos/bin/startup.sh -m standalone
/usr/local/nacos/bin/shutdown.sh
```

集群部署

```
# 数据库只需初始化一次
# 添加配置文件
vim /usr/local/nacos/conf/cluster.conf

10.xx.xx.1:8848
10.xx.xx.2:8848
10.xx.xx.3:8848
```

```
/usr/local/nacos/bin/startup.sh
/usr/local/nacos/bin/shutdown.sh
```

## 监控

```
vim /usr/local/nacos/conf/application.properties

management.endpoints.web.exposure.include=*
```

URL 10.xx.xx.1:8848/nacos/actuator/prometheus

