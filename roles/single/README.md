
dnf install -y gdal310
dnf install -y gdal310-devel
dnf install -y gdal310-java
dnf install -y gdal310-javadoc
dnf install -y gdal310-python-tools
dnf install -y gdal310-python3


dnf install -y postgis35_17
dnf install -y postgis35_17-client
dnf install -y postgis35_17-devel
dnf install -y postgis35_17-docs
dnf install -y postgis35_17-gui
dnf install -y postgis35_17-llvmjit
dnf install -y postgis35_17-utils


psql pgsql_testdb
create extension postgis





dnf install qgis python3-qgis qgis-grass qgis-server

https://velog.io/@dailylifecoding/import-shp-data-with-postgresql-and-qgis


### Check type of file
$ file -bi LSMD_CONT_LDREG_11_202505.shp
application/octet-stream; charset=binary

### Import Seoul Location Data downloaded from https://www.vworld.kr/dtmk/dtmk_ntads_s002.do?svcCde=MK&dsId=30563
$ shp2pgsql -I -s 5179 -W cp949 LSMD_CONT_LDREG_11_202505.shp | psql -h 192.168.2.191 -U jomoon -d pgsql_testdb


### References
- https://velog.io/@dailylifecoding/import-shp-data-with-postgresql-and-qgis
- https://www.endpointdev.com/blog/2018/02/regionating-with-postgis/
- https://medium.com/google-cloud/building-a-geospatial-application-with-alloydb-postgis-and-python-0a4105ef832c
- https://james-brennan.github.io/posts/postgis_python/
- https://www.crunchydata.com/blog/connecting-qgis-to-postgres-and-postgis


### Geographi Web Application for PostGIS
- https://towardsdatascience.com/spatial-data-science-with-postgresql-postgis-2f941c8c367a/
- https://rottengrapes.tech/blog/connect-postgis-with-pygeoapi

