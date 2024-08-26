版本：13.8.8

## 部署

```Shell
# 配置yum源
vim /etc/yum.repos.d/gitlab-ce.repo

[gitlab-ce]
name=Gitlab CE Repository
baseurl=https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el$releasever/
gpgcheck=0
enabled=1
```

```Shell
yum install -y gitlab-ce-13.8.8-ce.0.el7.x86_64
mkdir -p /data/gitlab
```

```
vim /etc/gitlab/gitlab.rb

# eg：external_url 'http://10.xx.xx.1:80'
external_url 'http://xxx.xxx.com'

# 备份
gitlab_rails['backup_path'] = "/data/gitlab/backups"
gitlab_rails['backup_keep_time'] = 172800  #2天 2*24*60*60

git_data_dirs({
  "default" => {
    "path" => "/data/gitlab"
   }
})
```

```Shell
gitlab-ctl reconfigure
```

## 备份脚本

```
mkdir -p /opt/gitlab/scripts
```

```
vim /opt/gitlab/scripts/backup.sh

#!/bin/bash
echo "start backup......"
date
/opt/gitlab/bin/gitlab-rake gitlab:backup:create
yes | cp /etc/gitlab/gitlab.rb /data/gitlab/backups/gitlab.rb
yes | cp /etc/gitlab/gitlab-secrets.json /data/gitlab/backups/gitlab-secrets.json
echo "end backup......"
date
```

```
crontab -e

0 2 * * * sh /opt/gitlab/scripts/backup.sh >>/opt/gitlab/scripts/backup.log
```

## 常用命令

```
# 查看日志
gitlab-ctl tail

# 启动所有gitlab组件
gitlab-ctl start

# 停止所有gitlab组件
gitlab-ctl stop

# 重启所有gitlab组件
gitlab-ctl restart

# 查看服务状态
gitlab-ctl status
```

## 常见问题

### 语言修改为中文

点击头像->Setting->Perference->Localization->Language->简体中文

### Admin管理页面提示500内部错误(500 Internal error)

```
# 遍历数据库中所有可能的加密值，验证它们是否可使用 gitlab-secrets.json解密
gitlab-rake gitlab:doctor:secrets

# 如果有无法解密的值，可以按照以下步骤重置它们
gitlab-rails dbconsole
UPDATE projects SET runners_token = null, runners_token_encrypted = null;
UPDATE namespaces SET runners_token = null, runners_token_encrypted = null;
UPDATE application_settings SET runners_registration_token_encrypted = null;
UPDATE application_settings SET encrypted_ci_jwt_signing_key = null;
UPDATE ci_runners SET token = null, token_encrypted = null;
exit

# 再次查看
gitlab-rake gitlab:doctor:secrets
```

### 重置root密码

```Shell
gitlab-rails console -e production
user = User.where(id: 1).first
user.password = 'Cosmo@2024'
user.password_confirmation = 'Cosmo@2024'
user.save!
exit
```
