import os

using_sae=True
using_sae=False

if using_sae:
    import sae

import web
web.DEBUG=False

import api

urls = (
)
urls = urls + api.urls

app_root = os.path.dirname(__file__)
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



