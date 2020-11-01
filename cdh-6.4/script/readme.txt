
# 安装之前必须同步时间服务设置

# 安装前简历互信
ssh-keygen
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

for i in `seq 77 79`;do
    scp -i .ssh/hadoop.pem  ~/.ssh/authorized_keys 172.31.33.$i:~/.ssh/
    scp -i .ssh/hadoop.pem  ~/.ssh/id_rsa 172.31.33.$i:~/.ssh/
done

# 开始安装
setp 1. master & node:
        sh init.sh  # 先配置主机列表

setp 2. master:
        sh master_install.sh
        exec `cat master_install.sh`

setp 3. node:
        sh node_install.sh


