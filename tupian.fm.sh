
cat_list="22 23 24 25 26 27 28"

pid_list=""
NCURR=16
function my_wget()
{
    wget -q "$1" &

    pid_list="$pid_list $!"

    while [ true ]; 
    do
        new_list=""
        n=0
        for pid in $pid_list;
        do
            if [ -e /proc/$pid -a /proc/$pid/exe ];
            then
                # exists
                n=$((n+1))
                new_list="$new_list $pid"
            fi
        done
        pid_list="$new_list"
        if [ $n -lt $NCURR ]; then
            break
        fi
        sleep 0.1
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

    TMP_FILE=tmp-postid-$cat-$paged
#    while [ $paged -ne 0 ];
#    do
        get_postid_list $cat $paged > $TMP_FILE
#        ret=`cat $TMP_FILE | is_list_end`
#        if [ "$ret" == "END" ]; then
#            paged=0
#        else
#            paged=$((paged+1))
#        fi

        cat $TMP_FILE | while read postid; 
        do
            TMP_FILE=tmp-pic-$1-$postid
            get_piclist_info $postid > $TMP_FILE
            
            title=`cat $TMP_FILE | filter_title`
            cat $TMP_FILE | filter_retina_pic_list | while read url;
            do
                my_wget "$url"
            done
            cat $TMP_FILE | filter_pic_list | while read url;
            do
                my_wget "$url"
            done
        done
#    done
}


function fetchall()
{
    for paged in "2 3 4 5 6 7 8";
    do
        for cat in $cat_list;
        do
            fetch_by_cat $cat $paged
        done
    done
}


fetchall
