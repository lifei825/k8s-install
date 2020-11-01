#!/usr/bin/env bash

work_dir=$1

cd ${work_dir}

# install helm
if ! [ -d linux-amd64 ];then
    wget https://storage.googleapis.com/kubernetes-helm/helm-v2.9.1-linux-amd64.tar.gz
    tar zxf helm-v2.9.1-linux-amd64.tar.gz
    cp -arf linux-amd64/helm /usr/local/bin/
fi

helm init --upgrade -i registry.cn-hangzhou.aliyuncs.com/google_containers/tiller:v2.9.1 --stable-repo-url https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts

helm list

# install istio
if ! [ -d istio-1.0.2 ];then
    wget https://github.com/istio/istio/releases/download/1.0.2/istio-1.0.2-linux.tar.gz
    tar zxf istio-1.0.2-linux.tar.gz
    # curl -L https://git.io/getLatestIstio | sh -
fi

cd istio-1.0.2

export PATH=$PWD/bin:$PATH

if ! grep PATH=$PWD/bin:$PATH ~/.bashrc;then
    echo "export PATH=$PWD/bin:$PATH" >> ~/.bashrc
fi

kubectl create namespace istio-system

kubectl create -f install/kubernetes/helm/helm-service-account.yaml

kubectl apply -f install/kubernetes/helm/istio/templates/crds.yaml

helm install install/kubernetes/helm/istio --name istio --namespace istio-system

kubectl get pods -n istio-system

