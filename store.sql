-- 存储表设计

drop database if exists picture;
create database picture;
use picture;

create table pic
(
    picid char(32) not null,
    picheight int unsigned not null default 0,
    picwidth int unsigned not null default 0,
    picsize bigint unsigned not null default 0,
    pictype char(32) not null,
    sourceurl text not null default '',
    sourcesite text not null default '',
    tagid text not null default '',
    bywho char(32) not null,
    datesubmit datetime not null,

    primary key (picid)
);

create table picfile
(
    picid char(32) not null,
    picdata mediumblob not null,

    primary key (picid)
);


create table tag
(
    tagid char(32) not null,
    tagname varchar(64) not null,
    picnumber bigint unsigned not null default 0,

    primary key (tagid)
);


create table app
(
    appkey char(32) not null,
    apppasswd char(64) not null,
    appname varchar(64) not null,
    appdesc text not null,

    primary key (appkey)
);

create table picexif
(
    picid char(32) not null,
    picexif text not null,

    primary key (picid)
);


