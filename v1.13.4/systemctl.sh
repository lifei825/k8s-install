#!/usr/bin/env bash

systemctl $1 kube-apiserver
systemctl $1 kube-scheduler
systemctl $1 kube-controller-manager
systemctl $1 kubelet
systemctl $1 kube-proxy
systemctl $1 docker
systemctl $1 etcd
systemctl $1 flanneld
systemctl $1 keepalived
systemctl $1 haproxy

exit 0