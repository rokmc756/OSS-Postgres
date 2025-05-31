# Ansible Role: Repmgr

[![CI](https://github.com/FLiPp3r90/ansible-role-repmgr/workflows/CI/badge.svg?event=push)](https://github.com/FLiPp3r90/ansible-role-repmgr/actions?query=workflow%3ACI)
[![Ansible Galaxy](https://img.shields.io/badge/ansible--galaxy-flipp3r90.repmgr-blue.svg)](https://galaxy.ansible.com/flipp3r90/repmgr/)

This role installs and configures repmgr for Postgresql replication

## Requirements
You need a PostgreSQL installation to use this role. 
But before you can deploy the whole role, you need to install repmgr first because you need the repmgr binaries when before starting the Postgresql database with repmgr shared preload libraries.

## Role Variables

See defaults/main.yml

## Dependencies

None.

## Usage

In the playbook for the master:

```yaml
- hosts: db
  roles:
    - FLiPp3r90/repmgr
  vars:
    repmgr_install_only: true

- hosts: db
  roles:
     - role: anxs/postgresql
     - role: FLiPp3r90/repmgr
  vars:
    repmgr_is_master: true
    repmgr_node_id: 1
```

In the playbook for the slave:

```yaml
- hosts: db
  roles:
    - FLiPp3r90/repmgr
  vars:
    repmgr_install_only: true

- hosts: db
  roles:
     - role: anxs/postgresql
     - role: FLiPp3r90/repmgr
  vars:
    repmgr_node_id: 2
    repmgr_clone_standby: true
    repmgr_register_standby: true
```

## Install Repmgr Cluster
~~~bash
$ make repmgr r=install s=pkgs
$ make repmgr r=init s=db
$ make repmgr r=enable s=ssl
$ make repmgr r=add s=user
$ make repmgr r=config s=primary
$ make repmgr r=register s=primary
$ make repmgr r=config s=standby
$ make repmgr r=clone s=standby
$ make repmgr r=register s=standby
~~~

## Uninstall Repmgr Cluster
~~~bash
$ make repmgr r=unregister s=standby
$ make repmgr r=unregister s=primary
$ make repmgr r=uninit s=db
$ make repmgr r=uninstall s=pkgs
~~~


## Tricks and Tips

You will need to create a `repmgr` user on your master database with
appropriate permissions.  This two things.

1. Create a database use `repmgr` with the permissions
   `SUPERUSER,REPLICATION,LOGIN`
2. Add an entry to the `pg_hba.conf` file giving explicit access to the
s   replication database to both the `repmgr` and the `postgres` users

  ```bash
  # pg_hba.conf
  host  replication  repmgr    192.168.0.0/16  trust
  host  replication  repmgr    10.0.0.0/8      trust
  host  replication  postgres  192.168.0.0/16  trust
  host  replication  postgres  10.0.0.0/8      trust

  ```

If you use Firewalld on your database hosts you have to ensure that the Postgresql port is open.

If you have stricted sshd access configured on your database hosts you have to ensure that the postgres os user is able to connect via ssh key to all cluster member.

You have to set sudo rules that grants postgresql user to start/stop/restart postgresql database. 


## License

Apache License 2.0

## Author Information

[FLiPp3r90](https://github.com/FLiPp3r90)


## References
- https://www.dbi-services.com/blog/postgresql-cluster-using-repmgr/
- https://www.enterprisedb.com/postgres-tutorials/how-implement-repmgr-postgresql-automatic-failover
- https://blog.naver.com/seuis398/222303179005
- https://gracefulsoul.github.io/postgresql/postgresql-repmgr/
- https://kandwkfd.tistory.com/46
- https://opensource-db.com/postgresql-automatic-failover-with-repmgr/
- https://medium.com/@kiwiv/failover-with-repmgr-and-automatic-failover-implementation-357278cb35d2

- https://www.enterprisedb.com/blog/repmgr-32-here-barman-support-and-brand-new-high-availability-features
- https://www.pythian.com/blog/technical-track/how-to-set-up-repmgr-with-witness-for-postgresql-10
- https://jhdatabase.tistory.com/entry/PostgreSQL-repmgr-%EA%B5%AC%EC%84%B1-Failover-test-part1



# Autofailover
- https://medium.com/@kiwiv/failover-with-repmgr-and-automatic-failover-implementation-357278cb35d2



## Rollback Primary to Standby
### On Standby
~~~bash
$ sudo systemctl stop postgresql-17
$ /usr/pgsql-17/bin/repmgr -h 192.168.2.191 -U repmgr -d repmgr -f /etc/repmgr/17/repmgr.conf standby clone --dry-run
$ /usr/pgsql-17/bin/repmgr -h 192.168.2.191 -U repmgr -d repmgr -f /etc/repmgr/17/repmgr.conf standby clone -F
$ /usr/pgsql-17/bin/repmgr -h 192.168.2.191 -U repmgr -d repmgr -f /etc/repmgr/17/repmgr.conf standby register --force
$ sudo systemctl start postgresql-17
~~~
### On Primary
~~~bash
$ /usr/pgsql-17/bin/repmgr -f /etc/repmgr/17/repmgr.conf cluster show
~~~


