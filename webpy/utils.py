# -*-coding: utf-8-*-

import mmh3
import binascii
#import sha

HASH_SEED=42

def hashid(data):
    hash = mmh3.hash_bytes(data, HASH_SEED)
    return binascii.hexlify(hash)

def getappinfo(ctx):
    x_app = ctx.env.get('X_APP', ',')
    val = x_app.split(',')
    if len(val) < 2:
        val = val + ['','']
    return val[0:2]
