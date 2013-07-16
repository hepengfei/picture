-- 存储表设计

drop database if exists picture;
create database picture character set = utf8 collate = utf8_bin;
use picture;

create table picinfo
(
    picid char(32) not null,
    picwidth int unsigned not null default 0,
    picheight int unsigned not null default 0,
    picbytes bigint unsigned not null default 0,
    picformat char(32) not null,
    picname varchar(255) not null,
    sourceurl text not null default '',
    sourcesite text not null default '',
    tagid text not null default '',
    bywho char(32) not null,
    datesubmit datetime not null,

    primary key (picid)
) character set = utf8 collate = utf8_bin;

create table picfile
(
    picid char(32) not null,
    picdata mediumblob not null,

    primary key (picid)
)character set = utf8 collate = utf8_bin;


create table tag
(
    tagid char(32) not null,
    tagname varchar(64) not null,
    picnumber bigint unsigned not null default 0,

    primary key (tagid)
)character set = utf8 collate = utf8_bin;


create table app
(
    appkey char(32) not null,
    apppasswd char(64) not null,
    appname varchar(64) not null,
    appdesc text not null,

    primary key (appkey)
)character set = utf8 collate = utf8_bin;

create table picexif
(
    picid char(32) not null,
    picexif text not null,

    primary key (picid)
)character set = utf8 collate = utf8_bin;


