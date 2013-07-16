import os
import sys

using_sae=True
#using_sae=False

if using_sae:
    import sae

app_root = os.path.dirname(__file__)
sys.path.append(app_root)

import web
web.DEBUG=True

import api

urls = (
     '/', 'index',
     '/index.html', 'index',
     '/view.html', 'view',
)
urls = urls + api.urls


def loadhtml(file):
    readonce=10
    datas = []
    with open(file) as f:
        while True:
            data = f.read(readonce)
            datas.append(data)
            if len(data) < readonce:
                break
    return "".join(datas)

index_html = loadhtml(app_root+'/index.html')
view_html = loadhtml(app_root+'/view.html')

class index:
    def GET(self):
        return index_html

class view:
    def GET(self):
        return view_html

templates_root = os.path.join(app_root, 'templates')
render = web.template.render(templates_root)

app = web.application(urls, globals(), autoreload=True)

# customize error pages
#app.notfound = views.notfound
#app.internalerror = views.internalerror

if __name__ == "__main__":      # for test
    app.run()
elif using_sae:
    application = sae.create_wsgi_app(app.wsgifunc())
else:                           # for mod_wsgi(recommend you to use nginx+uwsgi)
    application = app.wsgifunc()



