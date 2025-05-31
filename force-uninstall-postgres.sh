#!/bin/bash

# NET_ADDR="192.168.0"
# HOSTS="191 192 193 194 195"
# HOSTS="171 172 173 174 175"
# HOSTS="61 62 63 64 65"
# HOSTS="81 82 83 84 85"
# HOSTS="81 82 83 84 85"

HOSTS="191 192 193 194 195"
NET_ADDR="192.168.2"

for i in `echo $HOSTS`
do

    # ssh root@$NET_ADDR.$i "/usr/sbin/update-alternatives --install /usr/bin/python python /usr/bin/python2 1"
    # ssh root@$NET_ADDR.$i "/usr/sbin/alternatives --set python /usr/bin/python2"
    ssh root@$NET_ADDR.$i "systemctl stop pgautofailover"
    ssh root@$NET_ADDR.$i "killall postgres; killall postgres; killall postgres"
    ssh root@$NET_ADDR.$i "killall pg_autoctl; killall pg_autoctl; killall pg_autoctl"
    ssh root@$NET_ADDR.$i "yum -y remove vmware-postgres15 vmware-postgres14 vmware-postgres13 vmware-postgres postgresql postgresql-libs etcd"
    ssh root@$NET_ADDR.$i "yum remove python3 python3-libs -y"
    # ssh root@$NET_ADDR.$i "fuser -k -m /home/postgres"
    # ssh root@$NET_ADDR.$i "fuser -k -m /var/lib/pgsql"
    ssh root@$NET_ADDR.$i "kill -9 \$( lsof -t -u postgres )"
    ssh root@$NET_ADDR.$i "userdel -r postgres"
    ssh root@$NET_ADDR.$i "rm -rf /home/postgres/.local ; rm -rf /var/lib/pgsql/* ; rm -rf /var/lib/pgsql/.local /var/lib/pgsql/.config ; rm -rf /tmp/pg_autoctl /var/lib/pgsql/* /var/lib/pgsql/.bash_profile; ls -al /var/lib/pgsql"
    ssh root@$NET_ADDR.$i "rm -rf /home/postgres /var/lib/pgsql"

done

