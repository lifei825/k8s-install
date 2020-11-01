#!/usr/bin/env bash
set -e

ip=`ifconfig eth0 | awk -F '[ :]+' '/inet addr/{print $4}'`

hostnamectl set-hostname `awk '/'$ip'/{print $2}' config`

swapoff -a

sed -i '/ swap / s/^\\/\\(.*\\)$/#\\/\\1/g' /etc/fstab

echo """
vm.swappiness = 10
net.ipv4.ip_forward = 1
""" > /etc/sysctl.d/hadoop.conf

sysctl -p

sysctl -w net.ipv4.ip_forward=1

if ! grep "/sys/kernel/mm/transparent_hugepage" /etc/rc.local;then
	echo "echo never > /sys/kernel/mm/transparent_hugepage/defrag" >> /etc/rc.local
	echo "echo never > /sys/kernel/mm/transparent_hugepage/enabled" >> /etc/rc.local
fi

echo """
*     hard    nofile 65535
*     soft    nofile 65535
*	  soft    core   65535
*	  hard    core   65535
*     hard    nproc  65535
*     soft    nproc  65535
""" > /etc/security/limits.d/hadoop.conf

iptables -F && sudo iptables -X && sudo iptables -F -t nat && sudo iptables -X -t nat; iptables -P FORWARD ACCEPT

setenforce 0;sed -i 's/^SELINUX=.*/SELINUX=disabled/g'  /etc/selinux/config

cat config | while read line;do if ! grep "$line" /etc/hosts;then echo "$line" >> /etc/hosts;fi;done

