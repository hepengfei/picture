
cat_list="22 23 24 25 26 27 28"

pid_list=""
NCURR=64
PID_FILE="/tmp/tupian.fm.pids"
function my_wget()
{
    wget -q "$1" &

    echo "$!" >> $PID_FILE

    while [ true ]; 
    do
        > ${PID_FILE}.1
        cat ${PID_FILE} | while read pid;
        do
            if [ -e /proc/$pid -a /proc/$pid/exe ];
            then
                echo "$pid" >> ${PID_FILE}.1
            fi
        done
        mv ${PID_FILE}.1 $PID_FILE
        n=`wc -l $PID_FILE|cut -d' ' -f1`
        if [ $n -lt $NCURR ]; then
            break
        fi
        sleep 1
    done
}

function get_postid_list()
{
    cat=$1
    paged=$2

    curl -s "http://www.tupian.fm/?cat=$cat&paged=$paged"|grep 'article id' |sed 's/^.*id="post-//; s/" cl.*$//'
}

function is_list_end()
{
    gawk '{n++}END{if(n<10)print "END"; else "MORE"; }'
}

function get_piclist_info()
{
    postid=$1
curl -s "http://www.tupian.fm/?p=$postid"|grep -E '(entry-title)|(p=[0-9]*.*data-retina)|(<p><a .*<img)'|sed 's/^.* src="//;s/" .*$//'|sed 's/^\//http:\/\/www.tupian.fm\//'|sed 's/^.*<h1.*">/title: /;s/<\/h1>.*$//'
}

function filter_title()
{
    grep '^title'|sed 's/title: //'
}

function filter_pic_list()
{
    grep '^http://'
}

function filter_retina_pic_list()
{
    grep '^http://'|sed 's/-[0-9]*x[0-9]*//'
}


function is_post_end()
{
    gawk '{n++}END{if(n<12)print "END"; else "MORE"; }'
}

function fetch_by_cat()
{
    cat=$1
    paged=$2

    while [ $paged -ne 0 ];
    do
        echo ">>> cat= $cat paged= $paged <<<"
        TMP_FILE=tmp-postid-$cat-$paged
        get_postid_list $cat $paged > $TMP_FILE
        ret=`cat $TMP_FILE | is_list_end`
        if [ "$ret" == "END" ]; then
            paged=0
        else
            paged=$((paged+1))
        fi

        cat $TMP_FILE | while read postid; 
        do
            if [ "$postid" == "0" ]; # 结束标志
            then
                break
            fi

            TMP_FILE=tmp-pic-$1-$postid
            get_piclist_info $postid > $TMP_FILE
            
            title=`cat $TMP_FILE | filter_title`
            n=`cat $TMP_FILE | filter_pic_list | wc -l | cut -d' ' -f1`
            echo "$title $n"
            cat $TMP_FILE | filter_retina_pic_list | while read url;
            do
                my_wget "$url"
            done
            cat $TMP_FILE | filter_pic_list | while read url;
            do
                my_wget "$url"
            done
        done
    done
}


function fetchall()
{
    for cat in $cat_list;
    do
        fetch_by_cat $cat 8
    done
}


APPKEY="me"
APPPASSWD="aa"

SERVER="benben"

function request()
{
    method=$1
    path=$2
    file=$3
   
    if ! [ -z $file ];
    then
        file="-T $file"
    fi
    curl -v -X $method http://$SERVER/$path -H "X_APP: $APPKEY,$APPPASSWD" $file 2>&1
}

function get_result()
{
    grep -E '< HTTP|< ETag' |sed 's/\r//g' |gawk '/HTTP/{status=$3;}/ETag/{etag=$3;}END{printf("%d %s\n", status, etag);}'
}

GET_PIC_INFO="$HOME/Workspace/picture/test/get_pic_info.py"
function report_file()
{
    local picfile=$1
    local tagname=$2
    local picname="$3"

    if ! [ -f $picfile ]; then
        echo "file not exists, skip: $picfile $tagname $picname"
        return 0
    fi

    TMPFILE=/tmp/tmp.tupian.fm.report.$$

    request POST "pic/file/new" $picfile > $TMPFILE.http
    r=`cat $TMPFILE.http | get_result`
    r_http=`echo "$r"|cut -d' ' -f1`
    r_etag=`echo "$r"|cut -d' ' -f2`
    if [ $r_http -ne 201 ] && [ $r_http -ne 200 ]; then
        echo "upload $infofile failed! > $r|$r_http|$r_etag2"
        echo "$TMPFILE.http"
        return 1
    fi
    if [ -z $r_etag ]; then
        echo "upload $infofile etag error! > $r"
        return 1
    fi

    $GET_PIC_INFO $picfile $r_etag "$picname" "http://www.tupian.fm/" "tupian.fm" "$tagname" > $TMPFILE
    request POST "pic/info/$r_etag" $TMPFILE > $TMPFILE.http
    r=`cat $TMPFILE.http | get_result`
    r_http=`echo "$r"|cut -d' ' -f1`
    r_etag2=`echo "$r"|cut -d' ' -f2`
    if [ $r_http -ne 201 ] && [ $r_http -ne 200 ]; then
        echo "report $infofile failed! > $r|$r_http|$r_etag2"
        echo "$TMPFILE.http"
        cat $TMPFILE.http
        return 1
    fi
    if [ "$r_etag2" != "$r_etag" ]; then
        echo "report $infofile etag error! > $r $r_etag"
        return 1
    fi

    return 0
}

function filter_filename()
{
    gawk -F"/" '{print $NF}'
}

function report_from_localcache()
{
    cache_dir=$1
    reported_dir=$2

    for infofile in `ls $cache_dir/tmp-pic-*`;
    do
        echo $infofile
        tagname=`basename $infofile | cut -d'-' -f3`
        picname=`cat $infofile | filter_title`

        mainpic=`head -1 $infofile | filter_filename`

        nline=0
        if [ -f $infofile ]; then
            nline=`wc -l $infofile|cut -d' ' -f1`
        fi
        if [ $nline -lt 2 ] || [ -z "$picname" ] || [ -z "$mainpic" ];
        then
            continue
        fi

        report_file $cache_dir/$mainpic $tagname "$picname"
        if [ $? -ne 0 ]; then
            return $?
        else
            echo "reported $picname - $mainpic ok"
        fi
        

        n=0
        tail -n +3 $infofile | while read line;
        do
            n=$((n+1))
            picfile=`echo $line | filter_filename`
            
            report_file $cache_dir/$picfile $tagname "$picname-$n"
            if [ $? -ne 0 ]; then
                return
            else
                echo "reported $picname-$n - $picfile ok"
            fi
        done

        mv $infofile $reported_dir/

    done
}


$1 $2 $3

