#!/usr/bin/env bash

ca_path=${4-/home/work/k8s/cert}

node1=$1
node2=$2
node3=$3

cd ${ca_path}

cat > etcd-csr.json <<EOF
{
  "CN": "etcd",
  "hosts": [
    "127.0.0.1",
    "${node1}",
    "${node2}",
    "${node3}"
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
    -profile=kubernetes etcd-csr.json | cfssljson -bare etcd

tar zcf etcd-cert.tar.gz etcd*
