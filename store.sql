-- 存储表设计

drop database if exists picture;
create database picture;
use picture;

create table pic
(
    picid bigint unsigned not null default 0,
    picheight int unsigned not null default 0,
    picwidth int unsigned not null default 0,
    picsize bigint unsigned not null default 0,
    sourceurl text not null default '',
    sourcesite text not null default '',
    tagid text not null default '',
    datesubmit datetime not null,
    bywho bigint unsigned not null default 0,
    picdata mediumblob not null default '',

    primary key (picid)
);


create table tag
(
    tagid int unsigned not null default 0,
    tagname varchar(64) not null,
    picnumber bigint unsigned not null default 0,

    primary key (tagid)
);


create table app
(
    appkey bigint unsigned not null default 0,
    apppasswd char(64) not null default 0,
    appname varchar(64) not null,
    appdesc text not null,

    primary key (appkey)
);

create table picexif
(
    picid bigint unsigned not null default 0,
    picexif text not null,

    primary key (picid)
);


