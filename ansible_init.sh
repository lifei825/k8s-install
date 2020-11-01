#!/usr/bin/env bash
# 2018 TurboData, Inc. All rights reserved.

yum install python-devel mysql-devel zlib-devel openssl-devel libffi-devel

wget https://www.python.org/ftp/python/3.7.0/Python-3.7.0.tgz
tar zxf Python-3.7.0.tgz
cd Python-3.7.0/
./configure --with-ssl
make
make install

pip3 install virtualenv
virtualenv venv_py3 -p python3
source venv_py3/bin/activate
sudo curl https://bootstrap.pypa.io/get-pip.py | sudo python
pip install ansible 
pip install jmespath

(sudo grep ANSIBLE_HOST_KEY_CHECKING=False ~/.bash_profile || sudo echo export ANSIBLE_HOST_KEY_CHECKING=False >> ~/.bash_profile)

# rsync   -avzP -e "ssh -p 22022" /Users/lifei/PycharmProjects/turbodata/kubernetes-install/ root@127.0.0.1:/home/
