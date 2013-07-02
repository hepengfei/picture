
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


$1 $2 $3
halt -p
