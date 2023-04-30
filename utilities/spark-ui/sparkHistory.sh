#!/bin/bash
/usr/lib/spark/sbin/start-history-server.sh &
nohup python3 /tmp/webserver.py -m http.server 9977 
