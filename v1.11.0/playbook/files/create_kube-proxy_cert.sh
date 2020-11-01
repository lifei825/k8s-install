#!/usr/bin/env bash

ca_path=${1-/home/work/k8s/cert}
MASTER_VIP=$2
KUBE_APISERVER=https://${MASTER_VIP}:8443


cd ${ca_path}

cat > kube-proxy-csr.json <<EOF
{
  "CN": "system:kube-proxy",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "k8s",
      "OU": "4Paradigm"
    }
  ]
}
EOF

cfssl gencert -ca=${ca_path}/ca.pem \
  -ca-key=${ca_path}/ca-key.pem \
  -config=${ca_path}/ca-config.json \
  -profile=kubernetes  kube-proxy-csr.json | cfssljson -bare kube-proxy

# 创建和分发 kubeconfig 文件
kubectl config set-cluster kubernetes \
  --certificate-authority=${ca_path}/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config set-credentials kube-proxy \
  --client-certificate=kube-proxy.pem \
  --client-key=kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config set-context default \
  --cluster=kubernetes \
  --user=kube-proxy \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig

tar zcf kube-proxy-cert.tar.gz kube-proxy*