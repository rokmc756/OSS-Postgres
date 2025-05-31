# export PGDATA=/var/lib/pgdata/monitor
PGDATA=/var/lib/pgdata/monitor

/opt/vmware/postgres/15/bin/pg_autoctl enable ssl \
--ssl-ca-file /var/lib/pgsql/certs/ca.crt \
--ssl-crl-file /var/lib/pgsql/certs/ca.srl \
--server-cert /var/lib/pgsql/certs/server.crt \
--server-key /var/lib/pgsql/certs/server.key \
--ssl-mode verify-full \
--pgdata $PGDATA

# --pgctl /opt/vmware/postgres/15/bin/pg_ctl
# --auth trust \
# --hostname rk8-master \
