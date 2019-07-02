#!/bin/bash

sudo -E /etc/init.d/supervisor start

echo "idms IP : `hostname --ip-address`"
sleep 1
tail -f /var/log/idms.log
