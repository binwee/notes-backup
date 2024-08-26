拉取指定依赖
```
mvn dependency:get -DgroupId=[groupid] -DartifactId=[artifactid] -Dversion=[version]
```

打包跳过单元测试
```
mvn clean package -Dmaven.test.skip=true
```

配置node-sass镜像
```
npm config set sass_binary_site="https://cdn.npmmirror.com/binaries/node-sass
```