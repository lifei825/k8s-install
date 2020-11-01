#!/usr/bin/env bash

ca_path=${1-/home/work/k8s/cert}

cd ${ca_path}

master1=$2
master2=$3
master3=$4
MASTER_VIP=$5
CLUSTER_KUBERNETES_SVC_IP=$6

cat > kubernetes-csr.json <<EOF
{
  "CN": "kubernetes",
  "hosts": [
    "127.0.0.1",
    "${master1}",
    "${master2}",
    "${master3}",
    "${MASTER_VIP}",
    "${CLUSTER_KUBERNETES_SVC_IP}",
    "kubernetes",
    "kubernetes.default",
    "kubernetes.default.svc",
    "kubernetes.default.svc.cluster",
    "kubernetes.default.svc.cluster.local"
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
      "O": "k8s",
      "OU": "4Paradigm"
    }
  ]
}
EOF

cfssl gencert -ca=${ca_path}/ca.pem \
  -ca-key=${ca_path}/ca-key.pem \
  -config=${ca_path}/ca-config.json \
  -profile=kubernetes kubernetes-csr.json | cfssljson -bare kubernetes

# create metrics-server cert
cat > metrics-server-csr.json <<EOF
{
  "CN": "aggregator",
  "hosts": [],
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
  -ca-key=${ca_path}/ca-key.pem  \
  -config=${ca_path}/ca-config.json  \
  -profile=kubernetes metrics-server-csr.json | cfssljson -bare metrics-server

#tar zcf kubernetes-cert.tar.gz kubernetes* metrics-server*
