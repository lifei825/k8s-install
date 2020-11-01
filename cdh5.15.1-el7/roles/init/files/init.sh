#!/bin/bash

if ! grep "/sys/kernel/mm/transparent_hugepage" /etc/rc.local;then
	echo "echo never > /sys/kernel/mm/transparent_hugepage/defrag" >> /etc/rc.local
	echo "echo never > /sys/kernel/mm/transparent_hugepage/enabled" >> /etc/rc.local
fi
