#!/bin/bash

# HOSTS="81 82 83 84 85"
HOSTS="172"
# 172 173 174 175"

for i in `echo $HOSTS`
do
    ssh root@192.168.0.$i "killall python"
    ssh root@192.168.0.$i "killall python3"
    ssh root@192.168.0.$i "killall pgwatch2-daemon"
    ssh root@192.168.0.$i "systemctl stop grafana-server influxdb2"
    ssh root@192.168.0.$i "systemctl disable grafana-server influxdb2"
    ssh root@192.168.0.$i "systemctl stop prometheus postgres_exporter"
    ssh root@192.168.0.$i "systemctl disable prometheus postgres_exporter"
    ssh root@192.168.0.$i "yum remove -y grafana influxdb2"
    ssh root@192.168.0.$i "rm -rf /etc/grafana /etc/pgwatch2 /root/prometheus* /root/postgres_exporter*"
    ssh root@192.168.0.$i "rm -rf /root/prometheus-* /root/postgres_exporter-* /usr/local/bin/prometheus /usr/local/bin/postgres_exporter /etc/systemc/system/postgres_exporter.service /etc/systemd/system/prometheus.service"
    ssh root@192.168.0.$i "systemctl daemon-reload"
done
