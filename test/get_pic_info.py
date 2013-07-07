#!/usr/bin/env python

import Image
import sys
import os
import json
import cStringIO

picinfo={}

filename=sys.argv[1]

picinfo['picid']=sys.argv[2]
picinfo['picname']=sys.argv[3]
picinfo['sourceurl']=sys.argv[4]
picinfo['sourcesite']=sys.argv[5]
picinfo['tagname']=sys.argv[6]

img = Image.open(filename)

picinfo['picwidth']=img.size[1]
picinfo['picheight']=img.size[0]
picinfo['picbytes']=os.stat(filename).st_size
picinfo['picformat']=img.format


io=cStringIO.StringIO()
json.dump(picinfo, io, ensure_ascii=False)
print io.getvalue()


