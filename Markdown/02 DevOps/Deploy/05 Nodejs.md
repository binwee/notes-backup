版本：16.20.2

## 安装部署

```
wget https://nodejs.org/dist/v16.20.2/node-v16.20.2-linux-x64.tar.gz
tar -zxvf node-v16.20.2-linux-x64.tar.gz
mv node-v16.20.2-linux-x64 /usr/local/nodejs
chown -R root:root /usr/local/nodejs
echo 'export PATH=$PATH:/usr/local/nodejs/bin' >> /etc/profile
source /etc/profile
node -v
# 淘宝cnpm镜像
npm install -g cnpm --registry=https://registry.npmmirror.com
cnpm -v
npm config set registry https://registry.npmmirror.com
npm config get registry
```


