# cdh-install

## 安装前准备

### 安装ansible2.6
```
pip install ansible
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
### 如果是阿里云集群或没有内网的服务要开启ssh转发
```
ssh ip "ssh -qTfnN -D 1080 root@master"
echo proxy=socks5://127.0.0.1:1080 >> /etc/yum.conf
```

##  安装后手动执行图形界面操作
```
./cloudera-manager-installer.bin
http://master:7180
```
