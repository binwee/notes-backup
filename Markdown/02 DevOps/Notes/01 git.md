```
# 初始化一个git仓库
git init
# 从git仓库拷贝项目
git clone <url>
git clone https://username:password@github.com/xxx/xxx.git

# 配置用户名与邮箱
git config --global user.name '你的用户名'
git config --global user.email '你的邮箱'

# 取回远程分支，与本地分支合并
git pull origin <远程分支名>:<本地分支名>
# 取回特定分支的更新
git fetch origin <分支名>
# git fetch是将远程主机的最新内容拉到本地，用户在检查了以后决定是否合并到工作本机分支中。
# git pull则是将远程主机的最新内容拉下来后直接合并，即：git pull = git fetch + git merge，这样可能会产生冲突，需要手动解决。

# 将文件添加到缓存
# 全部
git add .
# 单个
git add <file>

# 撤销
# 撤销到上一次提交
git reset
# 单个
git reset <file>

# commit
git commit -m "message"
# 跳过add
git commit -am "message"

# 撤销 commit、不撤销git add
git reset --soft HEAD^
# 撤销 commit、撤销 git add
git reset --hard HEAD^

# 将本地的 master 分支推送到 origin 主机的 master 分支
git push origin master

# 查看提交历史
git log

# 使本地仓库回退到指定提交
git reset --hard <commit_id>
# 将本地更改强制推送到远程
git push --force

# 查看分支
git branch
# 创建分支
git branch <branchname>
# 将任意分支合并到到当前分支中去
git merge <branchname>
```

