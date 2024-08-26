版本：3.8.8

## 环境依赖

jdk8

## 安装部署

```
wget https://dlcdn.apache.org/maven/maven-3/3.8.8/binaries/apache-maven-3.8.8-bin.tar.gz
tar -zxvf apache-maven-3.8.8-bin.tar.gz
mv apache-maven-3.8.8 /usr/local/maven
echo 'export PATH=$PATH:/usr/local/maven/bin' >> /etc/profile
source /etc/profile
mvn -v
```

