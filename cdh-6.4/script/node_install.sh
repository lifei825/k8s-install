#!/usr/bin/env bash

# http://archive-primary.cloudera.com/cm5/cm/5/cloudera-manager-el6-cm5.14.4_x86_64.tar.gz

master=`awk '/master/{print $1}' /etc/hosts`

tar -zxf /home/cloudera-manager-el6-cm5.14.4_x86_64.tar.gz -C /opt
chown cloudera-scm.cloudera-scm  /opt  -R
rpm -ivh /home/oracle-j2sdk1.7-1.7.0+update67-1.x86_64.rpm
rpm -ivh /home/ntpdate-4.2.4p8-3.el6.centos.x86_64.rpm
rpm -ivh /home/ntp-4.2.4p8-3.el6.centos.x86_64.rpm

service ntpd start
ntpdate -u ${master}

sed -i "s/^server_host=.*/server_host=$master/"  /opt/cm-5.14.4/etc/cloudera-scm-agent/config.ini
/opt/cm-5.14.4/etc/init.d/cloudera-scm-agent start
