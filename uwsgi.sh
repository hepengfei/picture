
name="test-uwsgi"

uwsgi_kill()
{
  ps aux|grep "$name"|grep master|grep -v grep|head -1|gawk '{print "kill -9 " $2}'|bash
}


uwsgi_start()
{
  uwsgi --ini /data/hepengfei/Workspace/picture/webpy/uwsgi.conf
}

uwsgi_ps()
{
  ps aux|grep "$name"|grep -v grep
}


$1
