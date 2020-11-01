#!/usr/bin/bash


# ---------

# 生成 EncryptionConfig 所需的加密 key
ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)

# 最好使用 当前未用的网段 来定义服务网段和 Pod 网段

# 服务网段，部署前路由不可达，部署后集群内路由可达(kube-proxy 和 ipvs 保证)
SERVICE_CIDR="{{SERVICE_CIDR}}"

# Pod 网段，建议 /16 段地址，部署前路由不可达，部署后集群内路由可达(flanneld 保证)
CLUSTER_CIDR="{{CLUSTER_CIDR}}"

# 服务端口范围 (NodePort Range)
export NODE_PORT_RANGE="{{NODE_PORT_RANGE}}"

# 集群各机器 IP 数组
export NODE_IPS=("{{master1}}" "{{master2}}" "{{master3}}")

# 集群各 IP 对应的 主机名数组
export NODE_NAMES=(node1 node2 node3)

# kube-apiserver 的 VIP（HA 组件 keepalived 发布的 IP）
export MASTER_VIP="{{MASTER_VIP}}"

# kube-apiserver VIP 地址（HA 组件 haproxy 监听 8443 端口）
export KUBE_APISERVER="https://{{MASTER_VIP}}:8443"

# HA 节点，配置 VIP 的网络接口名称
export VIP_IF="eth0"

# etcd 集群服务地址列表
export ETCD_ENDPOINTS="https://{{master1}}:2379,https://{{master2}}:2379,https://{{master3}}:2379"

# etcd 集群间通信的 IP 和端口
export ETCD_NODES="node1=https://{{master1}}:2380,node2=https://{{master2}}:2380,node3=https://{{master3}}:2380"

# flanneld 网络配置前缀
export FLANNEL_ETCD_PREFIX="/kubernetes/network"

# kubernetes 服务 IP (一般是 SERVICE_CIDR 中第一个IP)
export CLUSTER_KUBERNETES_SVC_IP="{{CLUSTER_KUBERNETES_SVC_IP}}"

# 集群 DNS 服务 IP (从 SERVICE_CIDR 中预分配)
export CLUSTER_DNS_SVC_IP="{{CLUSTER_DNS_SVC_IP}}"

# 集群 DNS 域名
export CLUSTER_DNS_DOMAIN="{{CLUSTER_DNS_DOMAIN}}"

# 将二进制目录 /opt/k8s/bin 加到 PATH 中
export PATH="{{k8s_bin_path}}":$PATH