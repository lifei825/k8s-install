#!/usr/bin/env bash

k8s_pkg_path=$1
ca_path=$2
MASTER_VIP=$3

cd ${k8s_pkg_path}/server/kubernetes/cluster/addons/dashboard/
sed -i 's/k8s.gcr.io/siriuszg/g' dashboard-controller.yaml
sed -i '/spec/a\  type: NodePort'  dashboard-service.yaml

find . ! -name "*.yaml" -a  ! -name "." | xargs rm -rfv

kubectl create -f  .

kubectl get deployment kubernetes-dashboard  -n kube-system

kubectl --namespace kube-system get pods -o wide

kubectl get services kubernetes-dashboard -n kube-system

# 创建登录 Dashboard 的 token 和 kubeconfig 配置文件

KUBE_APISERVER=https://${MASTER_VIP}:8443

kubectl create sa dashboard-admin -n kube-system

kubectl create clusterrolebinding dashboard-admin --clusterrole=cluster-admin --serviceaccount=kube-system:dashboard-admin

ADMIN_SECRET=$(kubectl get secrets -n kube-system | grep dashboard-admin | awk '{print $1}')

DASHBOARD_LOGIN_TOKEN=$(kubectl describe secret -n kube-system ${ADMIN_SECRET} | grep -E '^token' | awk '{print $2}')

# 设置集群参数
kubectl config set-cluster kubernetes \
  --certificate-authority=${ca_path}/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=dashboard.kubeconfig

# 设置客户端认证参数，使用上面创建的 Token
kubectl config set-credentials dashboard_user \
  --token=${DASHBOARD_LOGIN_TOKEN} \
  --kubeconfig=dashboard.kubeconfig

# 设置上下文参数
kubectl config set-context default \
  --cluster=kubernetes \
  --user=dashboard_user \
  --kubeconfig=dashboard.kubeconfig

# 设置默认上下文
kubectl config use-context default --kubeconfig=dashboard.kubeconfig