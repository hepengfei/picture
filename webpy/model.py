# -*-coding: utf-8-*-

import web, datetime
import MySQLdb

db = web.database(dbn='mysql', host='192.168.1.103',
                  db='picture', user='root', passwd='kebing')

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
        return get_errno(err), ''
    if len(results) > 0:
        return 0, results[0].picdata
    else:
        return 0, ''

def picfile_delete(id):
    try:
        n_affected = db.delete('picfile', where='picid=$id', vars=locals())
        return 0, n_affected
    except MySQLdb.Error as err:
        return get_errno(err), 0
    

#              datesubmit=datetime.datetime.utcnow())
    
