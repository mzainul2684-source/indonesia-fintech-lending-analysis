select version() as mysql_version;

create database if not exists fintech_lending
	character set utf8mb4;
    
use fintech_lending;
select database() as database_aktif;