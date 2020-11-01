#!/usr/bin/env bash

ca_path=${1-/home/work/k8s/cert}
master1=$2
master2=$3
master3=$4
MASTER_VIP=$5

KUBE_APISERVER=https://${MASTER_VIP}:8443

cd ${ca_path}

cat > kube-scheduler-csr.json <<EOF
{
    "CN": "system:kube-scheduler",
    "hosts": [
      "127.0.0.1",
      "${master1}",
      "${master2}",
      "${master3}"
    ],
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
      {
        "C": "CN",
        "ST": "BeiJing",
        "L": "BeiJing",
        "O": "system:kube-scheduler",
        "OU": "4Paradigm"
      }
    ]
}
EOF

cfssl gencert -ca=${ca_path}/ca.pem \
  -ca-key=${ca_path}/ca-key.pem \
  -config=${ca_path}/ca-config.json \
  -profile=kubernetes kube-scheduler-csr.json | cfssljson -bare kube-scheduler

# 创建和分发 kubeconfig 文件
kubectl config set-cluster kubernetes \
  --certificate-authority=${ca_path}/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=kube-scheduler.kubeconfig

kubectl config set-credentials system:kube-scheduler \
  --client-certificate=kube-scheduler.pem \
  --client-key=kube-scheduler-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-scheduler.kubeconfig

kubectl config set-context system:kube-scheduler \
  --cluster=kubernetes \
  --user=system:kube-scheduler \
  --kubeconfig=kube-scheduler.kubeconfig

kubectl config use-context system:kube-scheduler --kubeconfig=kube-scheduler.kubeconfig

tar zcf kube-scheduler-cert.tar.gz kube-scheduler*
