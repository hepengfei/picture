
using_sae=True
using_sae=False

MYSQL_HOST = "localhost"
MYSQL_PORT = "3306"
MYSQL_DB = "picture3"
MYSQL_USER = "root"
MYSQL_PASS = ""

if using_sae:
    import sae.const
    MYSQL_HOST = sae.const.MYSQL_HOST
    MYSQL_PORT = sae.const.MYSQL_PORT
    MYSQL_DB = sae.const.MYSQL_DB
    MYSQL_USER = sae.const.MYSQL_USER
    MYSQL_PASS = sae.const.MYSQL_PASS

CACHE_PICINFO=86400
CACHE_PICINFOLIST=60

