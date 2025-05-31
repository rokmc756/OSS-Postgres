## What is PostgreSQL Cluster
postgres-cluster provide ansible playbook to deploy three kind of clusters such as gpfailover, patroni cluster, mutlti master replication ( bdr ).

## patroni cluster
https://github.com/rokmc756/postgres-cluster/tree/main/roles/vmware-patroni

## pg_auto_failover cluster
https://github.com/rokmc756/postgres-cluster/tree/main/roles/vmware-pgautofailover

## Reference links
https://www.techsupportpk.com/2020/02/how-to-create-highly-available-postgresql-cluster-using-patroni-haproxy-centos-rhel-7.html



## Error with sync mode
~~~
  File "/usr/lib/python3.6/site-packages/patroni/ha.py", line 1277, in _run_cycle
    return self.post_bootstrap()
  File "/usr/lib/python3.6/site-packages/patroni/ha.py", line 1173, in post_bootstrap
    self.cancel_initialization()
  File "/usr/lib/python3.6/site-packages/patroni/ha.py", line 1168, in cancel_initialization
    raise PatroniException('Failed to bootstrap cluster')
patroni.exceptions.PatroniException: 'Failed to bootstrap cluster'
~~~

## Replication modes
~~~
https://patroni.readthedocs.io/en/latest/replication_modes.html
~~~

## Replica imaging and bootstrap
~~~
https://patroni.readthedocs.io/en/latest/replica_bootstrap.html
~~~

## Enable SSL on pgautofailover
~~~
[postgres@rk8-master certs]$ /opt/vmware/postgres/15/bin/pg_autoctl enable ssl --pgdata /var/lib/pgsql/monitor/ --ssl-ca-file ./ca.key --ssl-crl-file ./ca.srl --server-key ./server.key --server-cert ./server.crt
21:11:57 54855 INFO  Using default --ssl-mode "verify-full"
21:11:57 54855 WARN  HBA rules in "/var/lib/pgsql/monitor/pg_hba.conf" have NOT been edited: "host"  records match either SSL or non-SSL connection attempts.
21:11:57 54855 INFO  Successfully enabled new SSL configuration:
21:11:57 54855 INFO    SSL is now active
21:11:57 54855 INFO    pg_autoctl service has been signaled to reload its configuration

moonjaYMD6T:vmware-postgres moonja$ psql -h rk8-master -U postgres
psql (14.7 (Homebrew), server 15.3 (VMware Postgres 15.3.0))
WARNING: psql major version 14, server major version 15.
         Some psql features might not work.
SSL connection (protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384, bits: 256, compression: off)
Type "help" for help.

postgres=# exit


# Disable SSL
[postgres@rk8-master certs]$ /opt/vmware/postgres/15/bin/pg_autoctl disable ssl --pgdata /var/lib/pgsql/monitor
21:19:44 60906 WARN  No encryption is used for network traffic! This allows an attacker on the network to read all replication data.
21:19:44 60906 WARN  Using --ssl-self-signed instead of --no-ssl is recommend to achieve more security with the same ease of deployment.
21:19:44 60906 WARN  See https://www.postgresql.org/docs/current/libpq-ssl.html for details on how to improve
21:19:44 60906 INFO  Using default --ssl-mode "prefer"
21:19:44 60906 WARN  HBA rules in "/var/lib/pgsql/monitor/pg_hba.conf" have NOT been edited: "host"  records match either SSL or non-SSL connection attempts.
21:19:44 60906 INFO  Successfully enabled new SSL configuration:
21:19:44 60906 INFO    SSL is now disabled
21:19:44 60906 INFO    pg_autoctl service has been signaled to reload its configuration

moonjaYMD6T:vmware-postgres moonja$ psql -h rk8-master -U postgres
psql (14.7 (Homebrew), server 15.3 (VMware Postgres 15.3.0))
WARNING: psql major version 14, server major version 15.
         Some psql features might not work.
Type "help" for help.

~~~

# SSL configure in patroni
https://docs.microfocus.com/doc/Operations_Orchestration/2023.05/HardeningPatroniCluster
https://access.crunchydata.com/documentation/patroni/2.0.1/environment/
https://patroni.readthedocs.io/en/master/ENVIRONMENT.html

# patroni cluster
https://docs.microfocus.com/doc/SMAX/23.4/HASQLPatroni
https://www.dbi-services.com/blog/how-to-setup-a-consul-cluster-on-rhel-8-rocky-linux-8-almalinux-8-part-2/

# For extra rpms
# sudo dnf install --nogpgcheck https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$(rpm -E %rhel).noarch.rpm

# Intall etcd binary
# https://computingforgeeks.com/how-to-install-etcd-on-rhel-centos-rocky-almalinux/
