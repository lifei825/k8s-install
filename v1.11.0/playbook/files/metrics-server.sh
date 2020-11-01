#!/usr/bin/env bash

ca_path=$1
work_dir=$2

cd ${ca_path}

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

#cfssl gencert -ca=${ca_path}/ca.pem \
#  -ca-key=${ca_path}/ca-key.pem  \
#  -config=${ca_path}/ca-config.json  \
#  -profile=kubernetes metrics-server-csr.json | cfssljson -bare metrics-server
#
#tar zcf metrics-server.tar.gz metrics-server*

# 修改插件配置文件配置文件
cd ${work_dir}

if ! [ -d metrics-server ];then
    git clone https://github.com/kubernetes-incubator/metrics-server
fi

cd metrics-server/deploy/1.8+/


cat > metrics-server-deployment.yaml <<EOF
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: metrics-server
  namespace: kube-system
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: metrics-server
  namespace: kube-system
  labels:
    k8s-app: metrics-server
spec:
  selector:
    matchLabels:
      k8s-app: metrics-server
  template:
    metadata:
      name: metrics-server
      labels:
        k8s-app: metrics-server
    spec:
      serviceAccountName: metrics-server
      volumes:
      # mount in tmp so we can safely use from-scratch images and/or read-only containers
      - name: tmp-dir
        emptyDir: {}
      containers:
      - name: metrics-server
        command:
          - /metrics-server
          - --kubelet-preferred-address-types=InternalIP
          - --kubelet-insecure-tls
        image: mirrorgooglecontainers/metrics-server-amd64:v0.3.0
        imagePullPolicy: Always
        volumeMounts:
        - name: tmp-dir
          mountPath: /tmp
EOF


cat > auth-kubelet.yaml <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: view-metrics
rules:
- apiGroups:
    - metrics.k8s.io
  resources:
    - pods
    - nodes
  verbs:
    - get
    - list
    - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: view-metrics
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: view-metrics
subjects:
  - apiGroup: rbac.authorization.k8s.io
    kind: User
    name: system:anonymous
EOF


# 创建 metrics-server
#find . ! -name "*.yaml" -a  ! -name "." | xargs rm -rfv

kubectl create -f .

# 查看运行情况
kubectl get pods -n kube-system |grep metrics-server
kubectl get svc -n kube-system|grep metrics-server
