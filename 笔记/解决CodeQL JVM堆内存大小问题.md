## 解决JVM内存大小不够导致的崩溃

- https://github.com/github/codeql/issues/5292
- https://github.com/github/codeql/issues/12255
- https://github.com/github/codeql/issues/6933

使用`CodeQL`的 `-J` 选项传入自定义参数 ， 定义`JVM`内存大小

```shell
codeql create database -J -Xmx4G -J -Xms4G ...
// 如果4G不够用的话，可以进行调整，例如16G
codeql create database -J -Xmx16G -J -Xms16G ...
```

