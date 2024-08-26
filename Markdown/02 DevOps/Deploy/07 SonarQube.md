
版本9.9.6

## 环境依赖

jdk17

11<= PostgreSQL <=15

## 默认端口

9000 web客户端

5432 postgresql

## 安装部署

安装postgresql

```
yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
yum install -y postgresql14-server
/usr/pgsql-14/bin/postgresql-14-setup initdb
systemctl enable --now postgresql-14
su - postgres
psql
ALTER USER postgres PASSWORD 'postgres';
CREATE USER sonarqube WITH PASSWORD 'sonarqube';
CREATE DATABASE sonarqube WITH OWNER sonarqube ENCODING 'UTF8';
\q
exit

```

安装jdk17

```
wget https://corretto.aws/downloads/latest/amazon-corretto-17-x64-linux-jdk.rpm
yum install -y java-17-amazon-corretto-*.rpm
java -version
```

安装sonarqube

```
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.9.6.92038.zip
unzip sonarqube-9.9.6.92038.zip
mv sonarqube-9.9.6.92038 /usr/local/sonarqube/
useradd sonarqube
chown -R sonarqube: /usr/local/sonarqube/
```

```
vim /usr/local/sonarqube/conf/sonar.properties

sonar.jdbc.username=sonarqube
sonar.jdbc.password=sonarqube
sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube
```

```
su - sonarqube
/usr/local/sonarqube/bin/linux-x86-64/sonar.sh start
exit
```

```
/usr/local/sonarqube/bin/linux-x86-64/sonar.sh stop
```

