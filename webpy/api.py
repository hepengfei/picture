# -*-coding: utf-8-*-

import web
import model
import utils

urls = (
    '/pic/file/new', 'api.PicFile',
    '/pic/file/([0-9a-zA-z]*)', 'api.PicFile',
    '/pic/info/([0-9a-zA-Z]*)', 'api.PicInfo',
)

def setpicid(ctx, id):
    ctx.headers.append(('ETag', str(id)))

class PicFile:
    def POST(self):
        appkey, apppasswd = utils.getappinfo(web.ctx)
        data=web.data()
        id=utils.hashid(data)
        setpicid(web.ctx, id)
        ret, n_affected = model.picfile_new(id, data)
        if ret != 0:
            web.ctx.status=500
        elif n_affected == 1:
            web.ctx.status=201
        else:
            web.ctx.status=200
        return ''
    def GET(self, id):
        appkey, apppasswd = utils.getappinfo(web.ctx)
        setpicid(web.ctx, id)
        ret, data=model.picfile_get(id)
        if ret == 0:
            if len(data) == 0:
                web.ctx.status = 404
            return data
        else:
            web.ctx.status = 500
            return ''
    def DELETE(self, id):
        appkey, apppasswd = utils.getappinfo(web.ctx)
        setpicid(web.ctx, id)
        ret, n_affected=model.picfile_delete(id)
        if ret == 0:
            if n_affected == 0:
                web.ctx.status = 404
        else:
            web.ctx.status = 500
        return ''
    
class PicInfo:
    def POST(self, id):
        pass
    def GET(self, id):
        return "hello " + id
    def DELETE(self, id):
        pass

class PicInfoList:
    def GET(self, offset, number):
        pass
    def GET(self, idlist):
        pass

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


