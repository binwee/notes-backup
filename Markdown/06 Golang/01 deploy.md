## Linux

```
wget https://golang.google.cn/dl/go1.20.14.linux-amd64.tar.gz
tar -zxvf go1.20.14.linux-amd64.tar.gz
mkdir -p /usr/local/go
mv go /usr/local/go/go1.20.14
mkdir -p /usr/local/go/gopath
```

```
vim /etc/profile

export GOROOT=/usr/local/go/go1.20.14
export GOPATH=/usr/local/go/gopath
export GO111MODULE=on
export GOPROXY=https://goproxy.cn,direct
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
```

```
source /etc/profile
```


## macOS（ARM）

```
https://golang.google.cn/dl/go1.20.14.darwin-arm64.tar.gz
```

解压后重命名为`go1.20.14`

```
sudo mkdir /usr/local/go
sudo mv go1.20.14 /usr/local/go/
```

创建GOPATH目录

```
sudo mkdir /usr/local/go/gopath
```

配置环境变量

```
vim ~/.zprofile

export GOROOT=/usr/local/go/go1.20.14
export GOPATH=/usr/local/go/gopath
export GO111MODULE=on
export GOPROXY=https://goproxy.cn,direct
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
```

```
source ~/.zprofile
```


