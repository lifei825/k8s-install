#!/usr/bin/env bash

pkg=${1-"/home/cdh_pkg_offline"}
rpm -ivh ${pkg}/utils/rsync-3.0.6-12.el6.x86_64.rpm
rpm -ivh ${pkg}/utils/perl-5.10.1-144.el6.x86_64.rpm
rpm -ivh ${pkg}/utils/git-1.7.1-9.el6_9.x86_64.rpm ${pkg}/utils/perl-Git-1.7.1-9.el6_9.noarch.rpm

ip=`ifconfig eth0 | awk -F '[ :]+' '/inet addr/{print $4}'`

hosts_arr=("172.31.33.77 cdh-master #cdh-master"
           "172.31.33.78 cdh-node1 #cdh-node"
           "172.31.33.79 cdh-node2 #cdh-node"
           )
hosts_num=${#hosts_arr[@]}

for n in `seq 0 ${hosts_num}`;do
    if ! grep "${hosts_arr[$n]}" /etc/hosts &>/dev/null;then
        echo ${hosts_arr[$n]} >> /etc/hosts
    fi

    if echo ${hosts_arr[$n]} | grep $ip &>/dev/null;then
        echo ${hosts_arr[$n]} | awk '/'$ip'/{system("hostname "$2)}'
        hostname=`echo ${hosts_arr[$n]} | awk '{print $2}' `
        sed -i 's/HOSTNAME=.*/HOSTNAME=${hostname}/'  /etc/sysconfig/network
    fi
done


swapoff -a

sed -i '/ swap / s/^\\/\\(.*\\)$/#\\/\\1/g' /etc/fstab

echo """
vm.swappiness = 10
net.ipv4.ip_forward = 1
""" > /etc/sysctl.d/cdh.conf

sysctl -p

sysctl -w net.ipv4.ip_forward=1

if ! grep "/sys/kernel/mm/transparent_hugepage" /etc/rc.local;then
	echo "echo never > /sys/kernel/mm/transparent_hugepage/defrag" >> /etc/rc.local
	echo "echo never > /sys/kernel/mm/transparent_hugepage/enabled" >> /etc/rc.local
fi

useradd --system --home=/opt/cloudera-manager/cm-5.0/run/cloudera-scm-server --no-create-home --shell=/bin/false --comment "Cloudera SCM User" cloudera-scm

echo """
*     hard    nofile 65535
*     soft    nofile 65535
*	  soft    core   65535
*	  hard    core   65535
*     hard    nproc  65535
*     soft    nproc  65535
""" > /etc/security/limits.d/cloudera-scm.conf

iptables -F && sudo iptables -X && sudo iptables -F -t nat && sudo iptables -X -t nat; iptables -P FORWARD ACCEPT

setenforce 0;sed -i 's/^SELINUX=.*/SELINUX=disabled/g'  /etc/selinux/config

mkdir -p /var/lib/cloudera-scm-server
mkdir -p /var/lib/cloudera-scm-agent
mkdir -p /var/lib/cloudera-scm-server-db/data


