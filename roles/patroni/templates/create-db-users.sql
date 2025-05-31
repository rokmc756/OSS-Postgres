
drop database if exists testdb
create database testdb;
create user jomoon with encrypted password 'changeme';
grant all privileges on database testdb to jomoon;

