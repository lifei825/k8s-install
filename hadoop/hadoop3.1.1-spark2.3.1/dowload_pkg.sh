#!/usr/bin/env bash

WORD_DIR=/home/work

[ -d ${WORD_DIR} ] || mkdir -pv ${WORD_DIR}

cd /home/work

wget http://mirrors.hust.edu.cn/apache/hadoop/common/hadoop-3.1.1/hadoop-3.1.1.tar.gz
wget http://mirrors.shu.edu.cn/apache/hadoop/common/hadoop-2.6.5/hadoop-2.6.5.tar.gz

wget http://mirror-hk.koddos.net/apache/spark/spark-2.3.1/spark-2.3.1-bin-hadoop2.7.tgz
wget http://mirrors.hust.edu.cn/apache/spark/spark-2.3.1/spark-2.3.1-bin-hadoop2.7.tgz
