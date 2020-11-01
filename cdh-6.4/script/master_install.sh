#!/usr/bin/env bash

# http://archive-primary.cloudera.com/cm5/cm/5/cloudera-manager-el6-cm5.14.4_x86_64.tar.gz
# https://dev.mysql.com/downloads/connector/j/

pkg=${1-"/home/cdh_pkg_offline"}
master=`awk '/master/{print $1}' /etc/hosts`

cp * ${pkg}/

cd ${pkg}

#
tar -zxf cloudera-manager-el6-cm5.14.4_x86_64.tar.gz -C /opt
/bin/cp CDH-5.14.4-1.cdh5.14.4.p0.3-el6.parcel /opt/cloudera/parcel-repo/
/bin/cp CDH-5.14.4-1.cdh5.14.4.p0.3-el6.parcel.sha1 /opt/cloudera/parcel-repo/CDH-5.14.4-1.cdh5.14.4.p0.3-el6.parcel.sha
/bin/cp manifest.json /opt/cloudera/parcel-repo/
chown cloudera-scm.cloudera-scm /opt -R

/bin/cp mysql-connector-java-* /opt/cm-5.14.4/share/cmf/lib/

sed -i "s/^server_host=.*/server_host=$master/" /opt/cm-5.14.4/etc/cloudera-scm-agent/config.ini


# mysql install:  https://dev.mysql.com/downloads/mysql/
rpm -ivh oracle-j2sdk1.7-1.7.0+update67-1.x86_64.rpm
rpm -ivh ntpdate-4.2.4p8-3.el6.centos.x86_64.rpm
rpm -ivh ntp-4.2.4p8-3.el6.centos.x86_64.rpm

cd mysql-pkg
tar xf MySQL-5.6.41-1.el6.x86_64.rpm-bundle.tar
rpm -e mysql-libs-5.1.73-8.el6_8.x86_64 --nodeps
rpm -ivh MySQL-devel-5.6.41-1.el6.x86_64.rpm
rpm -ivh MySQL-shared-5.6.41-1.el6.x86_64.rpm
rpm -ivh MySQL-shared-compat-5.6.41-1.el6.x86_64.rpm
rpm -ivh MySQL-client-5.6.41-1.el6.x86_64.rpm
rpm -ivh MySQL-test-5.6.41-1.el6.x86_64.rpm
rpm -ivh numactl-2.0.7-6.el6.x86_64.rpm
rpm -ivh numactl-devel-2.0.7-6.el6.x86_64.rpm
rpm -ivh MySQL-server-5.6.41-1.el6.x86_64.rpm
rpm -ivh MySQL-embedded-5.6.41-1.el6.x86_64.rpm

cat > /etc/ntp.conf << EOF
driftfile  /var/lib/ntp/drift
pidfile    /var/run/ntpd.pid
logfile    /var/log/ntp.log

# Access Control Support
restrict    default kod nomodify notrap nopeer noquery
restrict -6 default kod nomodify notrap nopeer noquery
restrict 127.0.0.1
restrict 192.168.0.0 mask 255.255.0.0 nomodify notrap nopeer noquery
restrict 172.16.0.0 mask 255.240.0.0 nomodify notrap nopeer noquery
restrict 100.64.0.0 mask 255.192.0.0 nomodify notrap nopeer noquery
restrict 10.0.0.0 mask 255.0.0.0 nomodify notrap nopeer noquery

# local clock
server 127.127.1.0
fudge  127.127.1.0 stratum 10
EOF
/etc/init.d/ntpd restart


/etc/init.d/mysql start
cat /root/.mysql_secret
echo "mysql root passwd: Turbodata-2018"
/usr/bin/mysql_secure_installation
mysql -uroot -pTurbodata-2018 < init.sql
/opt/cm-5.14.4/share/cmf/schema/scm_prepare_database.sh mysql scm scm_admin scm_admin



echo """
for i in `awk '/node/{print $1}' /etc/hosts`;do
    scp /home/cloudera-manager-el6-cm5.14.4_x86_64.tar.gz  \
    init.sh \
    node_install.sh \
    /home/oracle-j2sdk1.7-1.7.0+update67-1.x86_64.rpm \
    /home/ntpdate-4.2.4p8-3.el6.centos.x86_64.rpm \
    /home/ntp-4.2.4p8-3.el6.centos.x86_64.rpm $i:/home/
done

/opt/cm-5.14.4/etc/init.d/cloudera-scm-server start
/opt/cm-5.14.4/etc/init.d/cloudera-scm-agent start

# 本机时间做同步  创建集群前所有节点必须做好时间同步 并添加server配置
server 127.127.1.0
fudge  127.127.1.0 stratum 10

ntpdate -u master
"""




