## 环境准备

| 名称     | ip            | 配置      |
| :------- | :------------ | :-------- |
| Master01 | 10.203.52.146 | 2c 4g 45g |
| Master02 | 10.203.52.147 | 2c 4g 45g |
| NFS      | 10.203.52.148 | 1c 2g 45g |
| VIP      | 10.203.52.150 | /         |

```Shell
# 关闭防火墙
systemctl stop firewalld.service && systemctl disable firewalld.service

# 关闭selinux
sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config && setenforce 0
```

## 部署NFS

```Shell
# nfs节点操作：
# 安装nfs服务端
yum -y install nfs-utils
systemctl enable --now rpcbind
systemctl enable --now nfs
# 创建共享目录
mkdir -m 755 -p /data/jenkins
echo '/data/jenkins *(rw,sync,insecure,no_subtree_check,no_root_squash)' > /etc/exports
# 重启服务
systemctl restart rpcbind nfs

# master节点操作：
# 安装nfs
yum -y install nfs-utils
systemctl enable --now nfs
# 创建挂载目录并挂载
mkdir -m 777 -p /data/jenkins
echo '10.203.52.148:/data/jenkins /data/jenkins nfs defaults 0 0' >> /etc/fstab
mount -a
```

## 部署Jenkins

```Shell
# master节点操作：
# 安装java
wget http://mirror.centos.org/centos/7/os/x86_64/Packages/java-1.8.0-openjdk-1.8.0.262.b10-1.el7.x86_64.rpm
yum install -y java-1.8.0-openjdk-1.8.0.262.b10-1.el7.x86_64.rpm

# master逐个节点执行，第一台master完成jenkins初始化操作后，再操作其他其他节点
# 安装jenkins
wget https://archives.jenkins.io/redhat/jenkins-2.303-1.1.noarch.rpm
yum install -y jenkins-2.303-1.1.noarch.rpm
# 修改JENKINS_HOME
sed -i 's/JENKINS_HOME="\/var\/lib\/jenkins"/JENKINS_HOME="\/data\/jenkins"/' /etc/sysconfig/jenkins
# 运行、开机自启
systemctl start jenkins && /sbin/chkconfig jenkins on
# 第一台master初始化时设置url为vip，如下图：
```

打开http://10.203.52.146:8080/、http://10.203.52.147:8080/，第二台无需进行初始化操作，共享家目录成功

## 存在问题

经测试，发现同时运行两个前端页面存在如下问题：

在master01创建名为test的job，master02刷新页面等操作均无法同步

在master02通过在url发起reload请求，数据才能同步

所以不能使用负载均衡的方式来实现双活，因此选择通过keepalived实现vip漂移，漂移后发起reload请求的方式。

## 部署keepalived

```Shell
# master节点执行
yum install -y keepalived
mv /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf.bak
```

```Shell
# 修改配置文件
vim /etc/keepalived/keepalived.conf
global_defs {
    router_id jenkins
}

vrrp_script chk_service {
    script "/etc/keepalived/check_jenkins.sh"
    interval 2
}

vrrp_instance VI_1 {
    state BACKUP
    interface eth0
    virtual_router_id 51
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    track_script {
        chk_service
    }
    # 节点获得vip后，执行发起reload请求的脚本
    notify_master "/etc/keepalived/switch_master.sh"
    virtual_ipaddress {
        10.203.52.150
    }
}
```

```shell
# 监测服务状态脚本
vim /etc/keepalived/check_jenkins.sh
#!/bin/bash
num=`ps -ef | awk '{print $1}' | grep jenkins | wc -l`
if [ $num == 0 ];then
  exit 1
else
  exit 0
fi
```
```shell
# 节点获取到vip，发起reload请求的脚本
vim /etc/keepalived/switch_master.sh
#!/bin/bash

# 本地地址+端口
host="http://127.0.0.1:8080"
# 账号密码
credentials="admin:admin"
# 获取到cookie和crumb
output=$(curl -s -verbose "$host/crumbIssuer/api/json" --user "$credentials" 2>&1)
cookie=$(echo "$output" | grep -E 'Set-Cookie: JSESSIONID' | awk -F';' '{print $1}' | grep -oP 'JSESSIONID\.[^;]*')
crumb=$(echo "$output" | grep -Eo '"crumb":"[^"]+"' | awk -F'"' '{print $4}')
# 发起post请求reload接口
curl -s -XPOST --cookie "$cookie" -H "Jenkins-Crumb:$crumb" "$host/reload" --user "$credentials"
exit 0
```

```shell
chmod a+x /etc/keepalived/check_jenkins.sh
chmod a+x /etc/keepalived/switch_master.sh
systemctl enable --now keepalived
```

