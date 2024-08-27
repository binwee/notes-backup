文件服务器

```
server {
    listen 80;
    server_name www.xxx.com;
    charset utf-8;

    location / {
        root /data;
        autoindex on;
        autoindex_localtime on;
        autoindex_exact_size off;
    }
}
```

配置证书与http强跳https

```
server{

    listen 443 ssl;

    #填写证书绑定的域名
    server_name www.xxx.com;

    #填写证书文件绝对路径
    ssl_certificate /root/cert/xxx.pem;
    #填写证书私钥文件绝对路径
    ssl_certificate_key /root/cert/xxx.key;

    ssl_session_cache shared:SSL:1m;
    ssl_session_timeout 5m;

    ssl_ciphers HIGH:!aNULL:!MD5;

    #表示优先使用服务端加密套件。默认开启
    ssl_prefer_server_ciphers on;


    location / {
      proxy_pass  http://127.0.0.1:82;
    }
}
server {
    listen 80;
    #填写证书绑定的域名
    server_name www.xxx.com;
    #将所有HTTP请求通过rewrite指令重定向到HTTPS。
    rewrite ^(.*)$ https://$host$1;
    location / {
      proxy_pass  http://127.0.0.1:82;
    }
}
```

