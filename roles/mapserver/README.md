**Important : this playbook is quick'n dirty and work in progress. Carefully review before using it.**

This Ansible playbook aims at setting a MapServer tile server on a
Debian 10 Buster, inspired by
https://github.com/mapserver/mapserver/wiki/Rendering-OSM-data-on-Ubuntu-12.04
and https://github.com/mapserver/basemaps.

Here is a rough view of what will be set up (note: even with the following little import, be sure to have 3-4GB of available storage):

```
# Install PostgreSQL + PostGIS, Apache, the MapServer CGI, imposm
apt install postgis apache2 mapserver-bin cgi-mapserver libapache2-mod-mapcache imposm
# ...and some dev tools for the basemap
apt install make unzip wget git

# Create a dedicated database user with its own database
# (you can harden the password but remember to edit the basemap's Makefile)
# (unfortunately, I didn't manage to configure all the tools to use the unix socket. Ping me if you succeeded!)
su -c 'psql -c "CREATE USER osm WITH PASSWORD '"'"'osm'"'"';"' postgres
su -c "psql -c 'CREATE DATABASE osm WITH OWNER osm;'" postgres
su -c "psql -c 'CREATE EXTENSION postgis;' osm" postgres

# Download or clone an OSM basemap
# (in case of trouble, this tuto was tested with the commit 0c21924a1b1d20cea3acf35fc46256d019877338)
mkdir -p /srv/osm
cd /srv/osm
git clone "https://github.com/mapserver/basemaps"

# Initial (only needed once) download of worldwide shapefiles (~750MB)
# (the two zip files can be copied on following hosts to avoid the download)
cd basemaps/data
make

# Generation
# (here, you can customize the Makefile. For example the style (default, google, bing) and the database connection)
cd ..
make

# Finally, import data...
mkdir /srv/osm/imposm
cd /srv/osm/imposm

# Manually download some small .pbf files as a test
wget https://download.geofabrik.de/australia-oceania/new-caledonia-latest.osm.pbf
wget https://download.geofabrik.de/europe/iceland-latest.osm.pbf
# ...and import in PostGIS
imposm --mapping-file=/srv/osm/basemaps/imposm-mapping.py --proj=EPSG:3857 --read new-caledonia-latest.osm.pbf
imposm --mapping-file=/srv/osm/basemaps/imposm-mapping.py --proj=EPSG:3857 --read --merge-cache iceland-latest.osm.pbf
imposm --mapping-file=/srv/osm/basemaps/imposm-mapping.py --proj=EPSG:3857 --connection=postgis://osm:osm@localhost:5432/osm --write
imposm --mapping-file=/srv/osm/basemaps/imposm-mapping.py --proj=EPSG:3857 --connection=postgis://osm:osm@localhost:5432/osm --optimize
imposm --mapping-file=/srv/osm/basemaps/imposm-mapping.py --proj=EPSG:3857 --connection=postgis://osm:osm@localhost:5432/osm --deploy-production-tables

# Configure Apache, MapServer and MapCache
mkdir /srv/osm/mapcache
cp -i /usr/share/doc/libapache2-mod-mapcache/examples/mapcache.xml /srv/osm/mapcache/
# Change layer to 'default' and add a <MAP> pointer to the basemap, in mapcache > source > getmap > params
# Remember to adapt 'osm-default.map' if you changed the style in the basemap's Makefile (google, bing)
sed -i 's#^\([[:space:]]\+\)<LAYERS>.*</LAYERS>#\1<LAYERS>default</LAYERS>\n\1<MAP>/srv/osm/basemaps/osm-default.map</MAP>#' mapcache.xml
# Modify the url to point to the local CGI
sed -i 's#<url>.*#<url>http://localhost/cgi-bin/mapserv?</url>#' /srv/osm/mapcache/mapcache.xml
# And configure Apache
cd /etc/apache2
a2enmod cgi
a2disconf serve-cgi-bin.conf
sed -i 's/Require all granted/Require local/' conf-available/serve-cgi-bin.conf
sed -i 's%#Include conf-available/serve-cgi-bin.conf%Include conf-available/serve-cgi-bin.conf\n\tMapCacheAlias /mapcache "/srv/osm/mapcache/mapcache.xml"%' sites-available/000-default.conf
apache2ctl configtest
service apache2 restart
```

You can test it at http://your.server.name.tld/mapcache/demo/

## Back to Ansible

Most of the configuration should be available in the inventory.

It is launched usually like this : `ansible-playbook site.yml`

If you want to override the passwords within a vault :
```
ansible-vault create vault.yml
# vault.yml example (take variables' names from inventory, vars, ...) :
# ---
# password: mypass
ansible-playbook -e @vault.yml --ask-vault-pass site.yml
```

## Prerequisites

### Prerequisites for the hosts
Hosts should be accessible via SSH as the root user (else, add the usual
`remote_user`/`become` instructions in ansible.cfg) and with the Python
prerequisite of Ansible (usually `python-minimal`).

Only tested on Debian 10 amd64 so far, with Ansible 2.7.7.

Note : to test or to limit to one particular host :
```
ansible foo.bar.com -m ping
ansible-playbook -l foo.bar.com -v -C -D site.yml
```

## Directory layout

We follow (more or less) the recommendations of
https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html
with :
- `site.yml` : master playbook
- `ansible.cfg` and `inventory.yml` : the first one set up some default configurations and introduce the second one : the inventory.
- `roles/common/`, `roles/fooapp/` : the roles with their tree `tasks/main.yml`, `files/`, `handlers/main.yml`, ...
- `group_vars/group1.yml` and `host_vars/hostname1.yml` : variables dedicated to a group or a host respectively.

Note : contrary to some recommendations, I prefer to set some variables in
the inventory instead of `host_vars` and `group_vars`. For a small playbook
like this one, it seems acceptable and it makes it easier to look where to
adapt.

## TODO

- better cross-platform compatibility
- use osmosis ? Said to be better than imposm (warning: heavy Java dependencies...)
- check disk space ?

## License

[CC-0](https://creativecommons.org/publicdomain/zero/1.0/)


## References
- https://iskra.sarang.net/197

