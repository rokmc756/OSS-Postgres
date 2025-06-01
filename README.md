## What is OSS-Postgres Ansible Playbook?
It is ansible playbook to deploy OSS Postgres conveniently on Baremetal, Virtual Machines and Cloud Infrastructure.
It provide also pgwatch2 and grafana for monitoring features as well as SSL connection automatically when deploying it.
The main purpose of this project is actually very simple. Because there are many jobs to install different kind of OSS Postgres versions and reproduce issues & test features as a support
engineer. I just want to spend less time for it.

If you are working with OSS Postgrs such as Developer, Administrator, Field Engineer or Database Administrator you could also utilize it very conviently as saving time.
## Where is this ansible playbook from and how is it changed?

It's originated by itself.
## Supported OSS Postgres versions
* OSS Postgres 17.x
## Supported Platform and OS
* Virtual Machines
* Baremetal
* RHEL/CentOS/Rocky Linux 7.x, 8.x, 9.x
## Prerequisite
* MacOS or Fedora/CentOS/RHEL should have installed ansible as ansible host.
* Supported OS for ansible target host should be prepared with package repository configured such as yum, dnf and apt
## Prepare ansible host to run vmware-postgres ansible playbook
* MacOS
```yaml
$ xcode-select --install
$ brew install ansible
$ brew install https://raw.githubusercontent.com/kadwanev/bigboybrew/master/Library/Formula/sshpass.rb
```
* Fedora/CentOS/RHEL
```yaml
$ sudo yum install ansible
$ sudo yum install -y python3-netaddr
```
## Prepareing OS
* Configure Yum / Local & EPEL Repostiory
## Download / configure / run OSS Postgres
```yaml
$ git clone https://github.com/rokmc756/OSS-Postgres
$ cd OSS-Postgres
$ vi Makefile
~~ snip
ANSIBLE_HOST_PASS="changeme"    # It should be changed with password of user in ansible host that vmware-postgres would be run.
ANSIBLE_TARGET_PASS="changeme"  # It should be changed with password of sudo user in managed nodes that vmware-postgres would be installed.
~~ snip
```
## For Single OSS Postgres
#### 1) The Architecure of Single OSS Postgres with pgwatch2 and grafana
![alt text](https://github.com/rokmc756/vmware-postgres/blob/main/roles/pgwatch2/images/pgwatch2_architecture.png)
#### 2) Configure Inventory for Single OSS Postgres
```yaml
$ vi ansible-hosts-rk9-single
[all:vars]
ssh_key_filename="id_rsa"
remote_machine_username="jomoon"
remote_machine_password="changeme"

[monitors]
rk9-node01 ansible_ssh_host=192.168.2.191

[slave]
rk9-node02  ansible_ssh_host=192.168.2.192

[workers]
rk9-node03 ansible_ssh_host=192.168.2.193
rk9-node04 ansible_ssh_host=192.168.2.194
rk9-node05 ansible_ssh_host=192.168.2.195
```
#### 3) Configure variables for Single OSS Postgres
```yaml
$ vi roles/single/vars/main.yml
---
_ssl:
  ssl_dir: "{{ pgsql.base_dir }}/certs"
  ssl_days: 3660
  ssl_country: "KR"
  ssl_state: "Seoul"
  ssl_location: "Guro"
  ssl_organization: "OSS"
  ssl_organization_unit: "Tanzu"
  ssl_common_name: "jtest.pivotal.io"
  ssl_email: "jomoon@pivotal.io"
  enable: true
~~ snip
```
#### 4) Deploy Single OSS Postgres
```yaml
$ dnf versionlock openssl-*                   # For openssl-3.0.7-27 in Rocky 9.x
$ make single r=disable s=security
$ make single r=install s=pkgs
$ make single r=init s=postgres
$ make single r=add s=user
$ make single r=enable s=ssl

or
$ make single r=install s=all
```
#### 5) Deploy PGWatch2 Web and Daemon
```yaml
$ make pgwatch2 r=install s=pkgs
$ make pgwatch2 r=install s=db
$ make pgwatch2 r=install s=pip
$ make pgwatch2 r=install s=web
$ make pgwatch2 r=install s=daemon

or
$ make pgwatch2 r=install s=all
```
- Open http://rk9-node01:8080 for PGWatch2
#### 6) Deploy Grafana and Prometheus
```yaml
$ make grafana r=install s=go
$ make grafana r=install s=pip
$ make grafana r=install s=prometheus
$ make grafana r=install s=grafana
$ make grafana r=enable s=ssl

or
$ make grafana r=install s=all
```
- Open https://rk9-node01:3000 for Grafana
- Open http://rk9-node01:8086 for InfluxDB

#### 7) Destroy PGWatch2/Grafana and Single OSS-Postgres
```yaml
$ make single r=stop s=service
$ make single r=uninstall s=pkgs
$ make single r=enable s=security

or
$ make grafana r=uninstall s=all
$ make pgwatch2 r=uninstall s=all
$ make single r=uninstall s=all
```
## For Patroni Cluster
#### 1) The Architecture of Patroni Cluster
![alt text](https://github.com/rokmc756/vmware-postgres/blob/main/roles/patroni/images/patroni_architecture.jpeg)
#### 2) Configure Inventory for Patroni Cluster
$ vi ansible-hosts-rk9-patroni
```yaml
[all:vars]
ssh_key_filename="id_rsa"
remote_machine_username="jomoon"              # Replace with sudo user of vmware-postgres administrator
remote_machine_password="changeme"            # Replace with password of sudo user

[control]
rk9-node01 ansible_ssh_host=192.168.2.191

[workers]
rk9-node01 ansible_ssh_host=192.168.2.191
rk9-node02 ansible_ssh_host=192.168.2.192
rk9-node03 ansible_ssh_host=192.168.2.193
rk9-node04 ansible_ssh_host=192.168.2.194
rk9-node05 ansible_ssh_host=192.168.2.195
```

#### 3) Configure Variables for Patroni Cluster
```yaml
$ vi roles/patroni/vars/main.yml
---
_ssl:
  ssl_dir: "{{ pgsql.base_dir }}/certs"
  ssl_days: 3660
  ssl_country: "KR"
  ssl_state: "Seoul"
  ssl_location: "Guro"
  ssl_organization: "OSS"
  ssl_organization_unit: "Tanzu"
  ssl_common_name: "jtest.pivotal.io"
  ssl_email: "jomoon@pivotal.io"


# vmware-postgres15-patroni-3.2.0-1.el9.x86_64.rpm
_patroni:
  major_version: "3"
  minor_version: "2"
  patch_version: "0"
  build_version: "1"
  os_version: el9
  arch_type: x86_64
  bin_type: rpm
  bin_path: "{{ common.pgsql_bin_dir }}/patroni"
  ctl_path: "{{ common.pgsql_bin_dir }}/patronictl"
  cluster_name: patclu01
  sync_mode: True
  with_pkgs: True
  enable_ssl: True
  # false is for pgbackrest, not found yet how does pgbackrest
  # interactive with synchronous mode in patroni cluster
  # sync_mode: on    # one of node will be a Sync Standby role


_etcd:
  major_version: "3"
  minor_version: "3"
  patch_version: "27"
  build_version: ""
  arch_type: x86_64
  os_version: el9
  bin_type: rpm
  download_bin: false
  blank: " "
  # etcd 3.4.x and 3.5.x does not work for vmware-postgres 15.x versions
~~ snip
```
#### 4) Deploy Patroni Cluster
```yaml
$ dnf versionlock openssl-*                   # For openssl-3.0.7-27 in Rocky 9.x
$ make hosts r=init

or
$ make patroni r=config s=firewall
$ make patroni r=install s=pkgs
$ make patroni r=install s=etcd
$ make patroni r=config s=env
$ make patroni r=enable s=ssl
$ make patroni r=install s=patroni
$ make patroni r=add s=user

or
$ make patroni r=install s=all

```
#### 5) Destroy Patroni Cluster
```yaml
$ make patroni r=stop s=service
$ make patroni r=uninstall s=pkgs
$ make patroni r=remove s=env
$ make patroni r=disable s=firewall

or
$ make patroni r=uninstall s=all
```
## For PGAutoFailover Cluster
#### 1) The Architecture
![alt text](https://github.com/rokmc756/vmware-postgres/blob/main/roles/pgautofailover/images/pgautofailover_architecture.svg)

#### 2) Configure Inventory
$ vi ansible-hosts-rk9-pgautofailover
```yaml
[all:vars]
ssh_key_filename="id_rsa"
remote_machine_username="jomoon"
remote_machine_password="changeme"

# For OSS Postgres PGAutoFailover
[monitor]
rk9-node01 ansible_ssh_host=192.168.2.191

[primary]
rk9-node03 ansible_ssh_host=192.168.2.193

[secondary]
rk9-node04 ansible_ssh_host=192.168.2.194
rk9-node05 ansible_ssh_host=192.168.2.195

[workers]
rk9-node03 ansible_ssh_host=192.168.2.193
rk9-node04 ansible_ssh_host=192.168.2.194
rk9-node05 ansible_ssh_host=192.168.2.195
```

#### 3) Configure Variables for PGAutoFailover Cluster
```yaml
$ vi roles/pgautofailover/vars/main.yml
---
_pgfailover:
  monitor_database: monitor                           # Database names
  workers_database: ha
  app_database: appdb                                 # Application database name for replication
  bin_path: "{{ common.pgsql_bin_dir }}/"
  ctl_path: "{{ common.pgsql_bin_dir }}/"
  cluster_name: pgfailclu01
  sslmode: prefer   # require
  enable_ssl: true


_ssl:
  ssl_dir: "{{ pgsql.base_dir }}/certs"
  ssl_days: 3660
  ssl_country: "KR"
  ssl_state: "Seoul"
  ssl_location: "Guro"
  ssl_organization: "OSS"
  ssl_organization_unit: "Tanzu"
  ssl_common_name: "jtest.pivotal.io"
  ssl_email: "jomoon@pivotal.io"
  # enable_ssl_monitor: true
~~ snip
```
#### 4) Deploy PGAutoFailover Cluster
```yaml
$ dnf versionlock openssl-*                   # For openssl-3.0.7-27 in Rocky 9.x
$ make pgautofailover r=disable s=security
$ make pgautofailover r=install s=pkgs
$ make pgautofailover r=deploy s=monitor
$ make pgautofailover r=deploy s=primary
$ make pgautofailover r=deploy s=secondary
$ make pgautofailover r=add s=user

$ make pgautofailover r=create s=ssl c=key
$ make pgautofailover r=enable s=ssl c=monitor
$ make pgautofailover r=enable s=ssl c=workers

or
$ make pgautofailover r=install s=all
```

#### 5) Destroy PGAutoFailover Cluster
```yaml
$ make pgautofailover r=disable s=ssl c=workers
$ make pgautofailover r=disable s=ssl c=monitor
$ make pgautofailover r=stop s=service
$ make pgautofailover r=uninstall s=pkgs
$ make pgautofailover r=enable s=security

or
$ make pgautofailover r=uninstall s=all
```


## Planning
- [O] Need to fix SEGFAULT when enabling SSL for Patroni and PGAutoFailover - https://knowledge.broadcom.com/external/article/382919/master-panics-after-enabling-ssl-on-gree.html
- [ ] Change CentOS and Rocky Linux Mirror into Local Mirrors in Korea
- [ ] Add Monitoring Features With PGWatch2 and Grafana for Single Postgres, PGAutofailover and Patroni Cluster
- [ ] Add Additional Extensions Inlcuded in OSS-Postgres Zip File
- [ ] Add Falut Talerence Feature with Keepalived for PGAutofailover and Patroni Cluster
- [ ] Add Load Balance Feature with HAProxy for PGAutofailover and Patroni Cluster

