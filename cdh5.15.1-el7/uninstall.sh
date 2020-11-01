#!/usr/bin/env bash

echo /usr/share/cmf/uninstall-cloudera-manager.sh

yum -y remove cloudera*

rm -rf  /var/lib/cloudera-scm-*

rm -f  /var/lib/cloudera-scm-agent/cm_guid ; systemctl restart  cloudera-scm-agent

rm -Rf /usr/share/cmf /var/lib/cloudera* /var/cache/yum/cloudera* /var/log/cloudera* /var/run/cloudera*

rm -rf /opt/cloudera/parcels/.flood/

rm /tmp/.scm_prepare_node.lock

rm -Rf /var/lib/flume-ng /var/lib/hadoop* /var/lib/hue /var/lib/navigator /var/lib/oozie /var/lib/solr /var/lib/sqoop* /var/lib/zookeeper

rm -rf /run/cloudera-scm-agent/