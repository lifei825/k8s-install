# kubernetes-install

## 安装前准备

### 安装ansible2.6
```
pip install ansible jmespath
```

### add new role
```
mkdir -pv roles/init/{files,templates,tasks,handlers,vars,defaults,meta}
```

### 免密登录
```
ssh-keygen
for host in master.example.com \
  node1.example.com \
  node2.example.com; \
  do ssh-copy-id -i ~/.ssh/id_rsa.pub $host; \
done
```

### 提前下载二进制文件
```
wget https://dl.k8s.io/{{k8s_version}}/kubernetes-server-linux-amd64.tar.gz
wget https://github.com/coreos/etcd/releases/download/v3.3.9/etcd-v3.3.9-linux-amd64.tar.gz
拷贝至本机自定义路径:{{k8s_binaries_path}}
```
