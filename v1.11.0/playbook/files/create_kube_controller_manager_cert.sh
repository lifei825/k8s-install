#!/usr/bin/env bash

ca_path=${1-/home/work/k8s/cert}
master1=$2
master2=$3
master3=$4
MASTER_VIP=$5

cd ${ca_path}

cat > kube-controller-manager-csr.json <<EOF
{
    "CN": "system:kube-controller-manager",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "hosts": [
      "127.0.0.1",
      "${master1}",
      "${master2}",
      "${master3}"
    ],
    "names": [
      {
        "C": "CN",
        "ST": "BeiJing",
        "L": "BeiJing",
        "O": "system:kube-controller-manager",
        "OU": "4Paradigm"
      }
    ]
}
EOF

cfssl gencert -ca=${ca_path}/ca.pem \
  -ca-key=${ca_path}/ca-key.pem \
  -config=${ca_path}/ca-config.json \
  -profile=kubernetes kube-controller-manager-csr.json | cfssljson -bare kube-controller-manager

# 创建和分发 kubeconfig 文件
KUBE_APISERVER=https://${MASTER_VIP}:8443

kubectl config set-cluster kubernetes \
  --certificate-authority=${ca_path}/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=kube-controller-manager.kubeconfig

kubectl config set-credentials system:kube-controller-manager \
  --client-certificate=kube-controller-manager.pem \
  --client-key=kube-controller-manager-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-controller-manager.kubeconfig

kubectl config set-context system:kube-controller-manager \
  --cluster=kubernetes \
  --user=system:kube-controller-manager \
  --kubeconfig=kube-controller-manager.kubeconfig

kubectl config use-context system:kube-controller-manager --kubeconfig=kube-controller-manager.kubeconfig

tar zcf kube-controller-manager-cert.tar.gz kube-controller-manager*

