#!/usr/bin/env bash

k8s_pkg_path=$1
CLUSTER_DNS_SVC_IP=$2
CLUSTER_DNS_DOMAIN=$3

cd ${k8s_pkg_path}/cluster/addons/dns/coredns/
sed 's/__PILLAR__DNS__SERVER__/'${CLUSTER_DNS_SVC_IP}'/g;s/__PILLAR__DNS__DOMAIN__/'${CLUSTER_DNS_DOMAIN}'/g;s/k8s.gcr.io/coredns/' coredns.yaml.base > coredns.yaml
kubectl create -f coredns.yaml
kubectl get all -n kube-system
