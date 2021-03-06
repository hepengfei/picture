# -*-coding: utf-8-*-

import web
import model
import utils
import json
import cStringIO
import datetime
import const

urls = (
    '/pic/file/new', 'api.PicFile',
    '/pic/file/([0-9a-zA-Z.]*)', 'api.PicFile',
    '/pic/info/([0-9a-zA-Z]*)', 'api.PicInfo',
    '/pic/info/list/([0-9]*)/([0-9]*)', 'api.PicInfoList',
    '/pic/info/series/([0-9a-zA-Z]*)', 'api.PicInfoSeries',
)

def setetag(ctx, id):
    ctx.headers.append(('ETag', str(id)))

def setcachecontrol(ctx, sec):
    n = datetime.datetime.now()
    e = n + datetime.timedelta(days=30)
    ctx.headers.append(('Date',
                        n.strftime("%a, %d %b %Y %H:%M:%S GMT")))
    ctx.headers.append(('Expires',
                        e.strftime("%a, %d %b %Y %H:%M:%S GMT")))
    ctx.headers.append(('Cache-Control', 'public'))

def encode_dict_val(d, coding='utf-8'):
    for k in d.keys():
        if type(d[k]) == unicode:
            d[k] = d[k].encode(coding)
    return d

def encode_dict_key(d, coding='utf-8'):
    for k in d.keys():
        if type(k) == unicode:
            ke = k.encode(coding)
            v = d[k]
            del d[k]
            d[ke] = v
    return d

class PicFile:
    def POST(self):
        appkey, apppasswd = utils.getappinfo(web.ctx)
        data=web.data()
        id=utils.hashid(data)
        setetag(web.ctx, id)
        ret, n_affected = model.picfile_new(id, data)
        if ret != 0:
            return web.internalerror("")
        elif n_affected == 1:
            web.ctx.status="201 Created"
        else:
            web.ctx.status="200 OK"
        return ''
    def GET(self, id):
        if len(id) < 32:
            return web.notfound("error id")
        appkey, apppasswd = utils.getappinfo(web.ctx)
        # enable cacheing
        id = id[:32]
        setetag(web.ctx, id)
        etag = web.ctx.env.get('HTTP_IF_NONE_MATCH')
        if etag == id:
            web.ctx.status="304 Not Modified"
            return ''

        ret, data=model.picfile_get(id)
        if ret == 0:
            if data is None:
                return web.notfound("")
            ret, picinfo=model.picinfo_get(id)
            if ret == 0 and picinfo is not None:
                web.ctx.headers.append(
                    ('Content-Type',
                     'image/'+ str.lower(str(picinfo.picformat))))
            return data
        else:
            return web.internalerror("")
    def DELETE(self, id):
        if len(id) < 32:
            return web.notfound("error id")
        appkey, apppasswd = utils.getappinfo(web.ctx)
        setetag(web.ctx, id)
        ret, n_affected=model.picfile_delete(id)
        if ret != 0:
            return web.internalerror("")
        if n_affected == 0:
            return web.notfound("")

        return ''
    
class PicInfo:
    def POST(self, id):
        if len(id) != 32:
            return web.notfound("error id")
        appkey, apppasswd = utils.getappinfo(web.ctx)
        infostr=web.data()
        info=encode_dict_val(json.loads(str(infostr)), "utf-8")
        setetag(web.ctx, id)
        tagid=utils.hashid(info["tagname"])

        taginfo={"tagname":info["tagname"], "picnumber":0}
        ret, n_affected = model.tag_new(tagid, taginfo)
        if ret != 0:
            return web.internalerror("")

        info["tagid"]=tagid
        info["bywho"]=appkey
        ret, n_affected = model.picinfo_new(id, info)
        if ret != 0:
            return web.internalerror("")
        if n_affected == 1:
            web.ctx.status="201 Created"
        else:
            web.ctx.status="200 OK"
        return ""
    def GET(self, id):
        if len(id) != 32:
            return web.notfound("error id")
        appkey, apppasswd = utils.getappinfo(web.ctx)
        setetag(web.ctx, id)
        ret, info=model.picinfo_get(id)
        if ret != 0:
            return web.internalerror("")

        if info is None:
            return web.notfound("")

        ret, tag=model.tag_get(info.tagid)
        if ret != 0:
            return web.internalerror("")

        if tag is None:         # 不应该出现的情况!
            return web.internalerror("")

        info.tagname = tag.tagname
        del info['bywho']
        info["datesubmit"]=str(info["datesubmit"])
        setcachecontrol(web.ctx, const.CACHE_PICINFO)
        return json.dumps(encode_dict_val(info, "utf-8"), ensure_ascii=False)

    def DELETE(self, id):
        if len(id) != 32:
            return web.notfound("error id")
        appkey, apppasswd = utils.getappinfo(web.ctx)
        setetag(web.ctx, id)
        ret, n_affected=model.picinfo_delete(id)
        if ret != 0:
            return web.internalerror("")
        if n_affected == 0:
            return web.notfound("")
        return ''

class PicInfoList:
    def GET(self, offset, limit):
        appkey, apppasswd = utils.getappinfo(web.ctx)
        ret, results=model.picinfo_list_large(offset, limit)
        if ret != 0:
            return web.internalerror("")

        if results is None:
            return web.notfound("")

        io = cStringIO.StringIO()
        io.write("[\n")
        for info in results:
            del info['bywho']
            info["datesubmit"]=str(info["datesubmit"])
            ret, tag=model.tag_get(info.tagid)
            if ret != 0:
                return web.internalerror("")

            if tag is None:         # 不应该出现的情况!
                return web.internalerror("")

            info.tagname = tag.tagname
            json.dump(encode_dict_val(info), io, ensure_ascii=False)
            io.write(",\n")

        out = io.getvalue()
        outdata = out[:-2] + '\n]'
        input = web.input(callback=None)
        if input.callback is not None:
            outdata = "%s(%s)" % (str(input.callback), outdata)
        setcachecontrol(web.ctx, const.CACHE_PICINFOLIST)
        return outdata

class PicInfoSeries:
    def GET(self, id):
        print id
        if len(id) < 32:
            return web.notfound("error id")
        id = id[:32]
        appkey, apppasswd = utils.getappinfo(web.ctx)
        ret, info=model.picinfo_get(id)
        if ret != 0:
            return web.internalerror("")

        if info is None:
            return web.notfound("")

        ret, results = model.picinfo_series(info.picname)
        if ret != 0:
            return web.internalerror("")

        if results is None:
            return web.notfound("")

        io = cStringIO.StringIO()
        io.write("[\n")
        for info in results:
            del info['bywho']
            info["datesubmit"]=str(info["datesubmit"])
            ret, tag=model.tag_get(info.tagid)
            if ret != 0:
                return web.internalerror("")

            if tag is None:         # 不应该出现的情况!
                return web.internalerror("")

            info.tagname = tag.tagname
            json.dump(encode_dict_val(info), io, ensure_ascii=False)
            io.write(",\n")

        out = io.getvalue()
        outdata = out[:-2] + '\n]'
        input = web.input(callback=None)
        if input.callback is not None:
            outdata = "%s(%s)" % (str(input.callback), outdata)
        setcachecontrol(web.ctx, const.CACHE_PICINFOLIST)
        return outdata

#    def GET(self, idlist):
#        pass

class PicExifList:
    def GET(self, idlist):
        pass

class PicExif:
    def POST(self, id):
        pass
    def GET(self, id):
        pass
    def DELETE(self, id):
        pass


