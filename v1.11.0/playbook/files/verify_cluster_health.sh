#!/usr/bin/env bash

cd /tmp

kubectl get nodes

cat > nginx-ds.yml <<EOF
apiVersion: v1
kind: Service
metadata:
  name: nginx-ds
  labels:
    app: nginx-ds
spec:
  type: NodePort
  selector:
    app: nginx-ds
  ports:
  - name: http
    port: 80
    targetPort: 80
---
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  name: nginx-ds
  labels:
    addonmanager.kubernetes.io/mode: Reconcile
spec:
  template:
    metadata:
      labels:
        app: nginx-ds
    spec:
      containers:
      - name: my-nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
EOF

kubectl create -f nginx-ds.yml
service "nginx-ds" created
daemonset.extensions "nginx-ds" created

# 检查各 Node 上的 Pod IP 连通性
kubectl get pods  -o wide|grep nginx-ds

#kubectl get pods  -o wide|grep nginx-ds | awk 'system("ping -c3 "$6)'

# 检查服务 IP 和端口可达性
kubectl get svc |grep nginx-ds

kubectl get svc |grep nginx-ds | awk 'system("curl "$3" &>/dev/null && echo curl ok")'

# 检查服务的 NodePort 可达性
#kubectl get nodes | awk 'NR>1{system("curl "$1":8900")}'
