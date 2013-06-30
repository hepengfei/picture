# -*-coding: utf-8-*-

urls = (
    '/pic/file', 'api.PicFile',
    '/pic/info/([0-9a-zA-Z]*)', 'api.PicInfo',
)


class PicFile:
    def POST(self):
        pass
    def GET(self, picid):
        pass
    def DELETE(self, picid):
        pass
    
class PicInfo:
    def POST(self, picid):
        pass
    def GET(self, picid):
        return "hello " + picid
    def DELETE(self, picid):
        pass

class PicInfoList:
    def GET(self, offset, number):
        pass
    def GET(self, picidlist):
        pass

class PicExifList:
    def GET(self, picidlist):
        pass

class PicExif:
    def POST(self, picid):
        pass
    def GET(self, picid):
        pass
    def DELETE(self, picid):
        pass


