#!/usr/bin/env bash


ca_path=${1-/home/work/k8s/cert}
node_name=$2
MASTER_VIP=$3
node_path=${4}
KUBE_APISERVER=https://${MASTER_VIP}:8443

cd ${ca_path}

# 创建 token
export BOOTSTRAP_TOKEN=$(kubeadm token create \
  --description kubelet-bootstrap-token \
  --groups system:bootstrappers:${node_name} \
  --kubeconfig ~/.kube/config)

# 设置集群参数
kubectl config set-cluster kubernetes \
  --certificate-authority=${ca_path}/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=kubelet-bootstrap.kubeconfig

# 设置客户端认证参数
kubectl config set-credentials kubelet-bootstrap \
  --token=${BOOTSTRAP_TOKEN} \
  --kubeconfig=kubelet-bootstrap.kubeconfig

# 设置上下文参数
kubectl config set-context default \
  --cluster=kubernetes \
  --user=kubelet-bootstrap \
  --kubeconfig=kubelet-bootstrap.kubeconfig

# 设置默认上下文
kubectl config use-context default --kubeconfig=kubelet-bootstrap.kubeconfig

mv kubelet-bootstrap.kubeconfig ${node_path}/

# docker redhat pem
if ! [ -f /etc/rhsm/ca/redhat-uep.pem ];then
curl --socks5 127.0.0.1:1080 \
    http://mirror.centos.org/centos/7/os/x86_64/Packages/python-rhsm-certificates-1.19.10-1.el7_4.x86_64.rpm \
    -o python-rhsm-certificates-1.19.10-1.el7_4.x86_64.rpm

rpm2cpio python-rhsm-certificates-1.19.10-1.el7_4.x86_64.rpm | cpio -iv --to-stdout ./etc/rhsm/ca/redhat-uep.pem | tee /etc/rhsm/ca/redhat-uep.pem
fi