#!/usr/bin/env bash

pkg=/home/cdh_pkg_offline

sh init.sh ${pkg}

sh master_install.sh ${pkg}
if [ $? -eq 0 ];then
    echo master install ok >> /tmp/cdh_install.log
fi

for i in `awk '/node/{print $1}' /etc/hosts`;do
    scp ${pkg}/cloudera-manager-el6-cm5.14.4_x86_64.tar.gz  \
    init.sh \
    node_install.sh \
    ${pkg}/oracle-j2sdk1.7-1.7.0+update67-1.x86_64.rpm \
    ${pkg}/ntpdate-4.2.4p8-3.el6.centos.x86_64.rpm \
    ${pkg}/ntp-4.2.4p8-3.el6.centos.x86_64.rpm $i:/home/

    ssh $i 'sh /home/init.sh'
    ssh $i 'sh /home/node_install.sh'

    if [ $? -eq 0 ];then
        echo $i install ok >> /tmp/cdh_install.log
    fi
done

/opt/cm-5.14.4/etc/init.d/cloudera-scm-server start
/opt/cm-5.14.4/etc/init.d/cloudera-scm-agent start

echo """
tailf /opt/cm-5.14.4/log/cloudera-scm-server/cloudera-scm-server.log
curl http://master:7180

test:
hadoop fs -mkdir  /tmp/test
hadoop fs -put init.sh  /tmp/test/
hadoop fs -cat   /tmp/test/init.sh

sh start_install.sh
"""

