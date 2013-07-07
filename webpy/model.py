# -*-coding: utf-8-*-

import web, datetime
import MySQLdb

db = web.database(dbn='mysql', host='localhost',
                  db='picture', user='root', passwd='')

def get_errno(err):
    return int(str(err)[1:10].split(',')[0])

def picfile_new(id, data):
    try:
        db.insert('picfile', picid=id, picdata=data)
    except MySQLdb.IntegrityError as err:
        return 0, 0
    except MySQLdb.Error as err:
        return get_errno(err), 0
    return 0, 1

def picfile_get(id):
    try:
        results = db.select('picfile', where='picid=$id', vars=locals())
    except MySQLdb.Error as err:
        return get_errno(err), None
    if len(results) > 0:
        return 0, results[0].picdata
    else:
        return 0, None

def picfile_delete(id):
    try:
        n_affected = db.delete('picfile', where='picid=$id', vars=locals())
        return 0, n_affected
    except MySQLdb.Error as err:
        return get_errno(err), 0
    

def picinfo_new(id, info):
    try:
        db.insert('picinfo', picid=id, 
                  picwidth=info["picwidth"],
                  picheight=info["picheight"],
                  picbytes=info["picbytes"],
                  picformat=info["picformat"],
                  picname=info["picname"],
                  sourceurl=info["sourceurl"],
                  sourcesite=info["sourcesite"],
                  tagid=info["tagid"],
                  bywho=info["bywho"],
                  datesubmit=datetime.datetime.utcnow())
    except MySQLdb.IntegrityError as err:
        return 0, 0
    except MySQLdb.Error as err:
        return get_errno(err), 0
    return 0, 1


def picinfo_get(id):
    try:
        results = db.select('picinfo', where='picid=$id', vars=locals())
    except MySQLdb.Error as err:
        return get_errno(err), None
    if len(results) > 0:
        return 0, results[0]
    else:
        return 0, None

def picinfo_list(offset, limit):
    try:
        results = db.select('picinfo', offset=offset, limit=limit)
    except MySQLdb.Error as err:
        return get_errno(err), None
    if len(results) > 0:
        return 0, results
    else:
        return 0, None

def picinfo_list_large(offset, limit):
    try:
        results = db.select('picinfo', offset=offset, limit=limit,
                            where="picheight>400")
    except MySQLdb.Error as err:
        return get_errno(err), None
    if len(results) > 0:
        return 0, results
    else:
        return 0, None


def picinfo_delete(id):
    try:
        n_affected = db.delete('picinfo', where='picid=$id', vars=locals())
        return 0, n_affected
    except MySQLdb.Error as err:
        return get_errno(err), 0
    
def tag_new(id, taginfo):
    try:
        db.insert('tag', tagid=id,
                  tagname=taginfo["tagname"],
                  picnumber=taginfo["picnumber"])
    except MySQLdb.IntegrityError as err:
        return 0, 0
    except MySQLdb.Error as err:
        return get_errno(err), 0
    return 0, 1

def tag_get(id):
    try:
        results = db.select('tag', where='tagid=$id', vars=locals())
    except MySQLdb.Error as err:
        return get_errno(err), None
    if len(results) > 0:
        return 0, results[0]
    else:
        return 0, None

def tag_delete(id):
    try:
        n_affected = db.delete('tag', where='tagid=$id', vars=locals())
        return 0, n_affected
    except MySQLdb.Error as err:
        return get_errno(err), 0
    
    
def app_new(id, appinfo):
    try:
        db.insert('app', appkey=id,
                  apppasswd=appinfo["apppasswd"],
                  appname=appinfo["appname"],
                  appdesc=info["appdesc"])
    except MySQLdb.IntegrityError as err:
        return 0, 0
    except MySQLdb.Error as err:
        return get_errno(err), 0
    return 0, 1

def app_get(id):
    try:
        results = db.select('app', where='appkey=$id', vars=locals())
    except MySQLdb.Error as err:
        return get_errno(err), None
    if len(results) > 0:
        return 0, results[0]
    else:
        return 0, None

def app_delete(id):
    try:
        n_affected = db.delete('app', where='appkey=$id', vars=locals())
        return 0, n_affected
    except MySQLdb.Error as err:
        return get_errno(err), 0
    

    
