#!/usr/bin/env bash

ca_path=${1-/home/work/k8s/cert}

cd ${ca_path}

cat > flanneld-csr.json <<EOF
{
  "CN": "flanneld",
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
  -ca-key=${ca_path}/ca-key.pem \
  -config=${ca_path}/ca-config.json \
  -profile=kubernetes flanneld-csr.json | cfssljson -bare flanneld

tar zcf flannel-cert.tar.gz flanneld*

