#!/usr/bin/env bash


cd /tmp/

if ! [ -f heapster-1.5.3.tar.gz ];then
    wget https://github.com/kubernetes/heapster/archive/v1.5.3.tar.gz
    mv v1.5.3.tar.gz heapster-1.5.3.tar.gz
fi

tar -zxf heapster-1.5.3.tar.gz

cd heapster-1.5.3/deploy/kube-config/influxdb

sed -i 's/gcr.io\/google_containers/registry.cn-shenzhen.aliyuncs.com\/rancher_cn/g' grafana.yaml

sed -i 's/gcr.io\/google_containers/fishchen/g;s/kubernetes.default/kubernetes.default?kubeletHttps=true\&kubeletPort=10250/' heapster.yaml

sed -i 's/gcr.io\/google_containers/fishchen/g' influxdb.yaml

kubectl create -f  .

cd ../rbac/

cat > heapster-rbac.yaml <<EOF
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: heapster
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:heapster
subjects:
- kind: ServiceAccount
  name: heapster
  namespace: kube-system
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: heapster-kubelet-api
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:kubelet-api-admin
subjects:
- kind: ServiceAccount
  name: heapster
  namespace: kube-system
EOF

kubectl create -f heapster-rbac.yaml

kubectl get pods -n kube-system | grep -E 'heapster|monitoring'

kubectl cluster-info




