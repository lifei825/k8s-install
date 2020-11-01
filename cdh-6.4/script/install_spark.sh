#!/bin/bash
path=/home/cdh_pkg_offline
pkg=spark-2.3.1-bin-hadoop2.7-cdh
master=`awk '/master/{print $2}' /etc/hosts`

pkg_path=${path}/${pkg}

for i in `awk '/master|node/{print $1}' /etc/hosts`;do
	scp ${path}/utils/rsync-3.0.6-12.el6.x86_64.rpm ${i}:/opt/
	ssh ${i} rpm -ivh /opt/rsync-3.0.6-12.el6.x86_64.rpm
done

rm -f /usr/bin/spark-shell  /usr/bin/pyspark

awk '/master|node/{print $2}' /etc/hosts > ${pkg_path}/conf/slaves

cat > ${pkg_path}/conf/spark-env.sh <<EOF
#!/usr/bin/env bash
export HADOOP_CONF_DIR=/opt/cloudera/parcels/CDH-5.14.4-1.cdh5.14.4.p0.3/lib/hadoop/etc/hadoop
export JAVA_HOME=/usr/java/jdk1.8.0_181-amd64/
export SPARK_HOME=${pkg_path}
export SPARK_MASTER_IP=${master}
export SPARK_EXECUTOR_MEMORY=5G
EOF

cat > ~/.bashrc <<EOF
# .bashrc

# User specific aliases and functions

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

export SPARK_HOME=${pkg_path}
export JAVA_HOME=/usr/java/jdk1.8.0_181-amd64
export JRE_HOME=/usr/java/jdk1.8.0_181-amd64/jre
export CLASSPATH=.:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar:\$JRE_HOME/lib
PATH=\$PATH:\$SPARK_HOME/bin

export PATH
EOF

for i in `awk '/node/{print $1}' /etc/hosts`;do
	rsync -a ${pkg_path} $i:${path}
	rsync -a ~/.bashrc $i:~/.bashrc
	ssh $i rpm -ivh ${pkg_path}/jdk-8u181-linux-x64.rpm
done
rpm -ivh ${pkg_path}/jdk-8u181-linux-x64.rpm

${pkg_path}/sbin/start-all.sh

jps

# install zeppelin
echo """
tar -zxf  ${pkg}/utils/zeppelin-0.8.0-bin-netinst.tgz -C /home/
cd /home/zeppelin-0.8.0-bin-netinst
echo "export SPARK_HOME=${pkg_path}" >> conf/zeppelin-env.sh
cp conf/zeppelin-site.xml.template conf/zeppelin-site.xml
sed -i "s/8080/8181/g" conf/zeppelin-site.xml
./bin/zeppelin-daemon.sh start
tailf logs/zeppelin-root-cdh-master.log
"""
