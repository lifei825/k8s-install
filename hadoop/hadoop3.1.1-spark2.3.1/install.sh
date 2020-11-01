#!/usr/bin/env bash

hadoop_version=${1-"2.6.5"}



cat > /root/.bashrc <<EOF
# .bashrc

# User specific aliases and functions

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi
export JAVA_HOME=/usr/java/jdk1.8.0_181-amd64/
export HADOOP_HOME=/home/hadoop-${hadoop_version}
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export PATH=$PATH:$HADOOP_HOME/bin
EOF

source /root/.bashrc

cat > ${HADOOP_HOME}/etc/hadoop/core-site.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
	<property>
        	<name>fs.defaultFS</name>
        	<value>hdfs://master:9000</value>
        	<description>HDFS的URI，文件系统://namenode标识:端口号</description>
        </property>
	<property>
            	<name>hadoop.tmp.dir</name>
             	<value>${HADOOP_HOME}/tmp</value>
             	<description>namenode上本地的hadoop临时文件夹</description>
        </property>
</configuration>
EOF

cat > ${HADOOP_HOME}/etc/hadoop/hadoop-env.sh <<EOF
export HADOOP_OS_TYPE=${HADOOP_OS_TYPE:-$(uname -s)}
# export HADOOP_OPTIONAL_TOOLS="hadoop-aliyun"
export JAVA_HOME=/usr/java/jdk1.8.0_181-amd64/
export HDFS_DATANODE_USER=root
export HDFS_SECONDARYNAMENODE_USER=root
export HDFS_NAMENODE_USER=root
export YARN_RESOURCEMANAGER_USER=root
export YARN_NODEMANAGER_USER=root
export HADOOP_HOME=/home/hadoop-${hadoop_version}
EOF

cat > ${HADOOP_HOME}/etc/hadoop/hdfs-site.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
        <!-- 设置namenode存放的路径 -->
        <property>
            <name>dfs.namenode.name.dir</name>
            <value>${HADOOP_HOME}/name</value>
        </property>
        <!-- 设置hdfs副本数量 -->
        <property>
            <name>dfs.replication</name>
            <value>2</value>
        </property>
        <!-- 设置datanode存放的路径 -->
        <property>
            <name>dfs.datanode.data.dir</name>
            <value>${HADOOP_HOME}/data</value>
        </property>
</configuration>
EOF

${HADOOP_HOME}/bin/hdfs namenode -format

${HADOOP_HOME}/sbin/start-all.sh