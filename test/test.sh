
APPKEY="me"
APPPASSWD="aa"

SERVER="meinvjzy.sinaapp.com"

function request()
{
    method=$1
    path=$2
    file=$3
   
    if ! [ -z $file ];
    then
        file="-T $file"
    fi
    curl -s -v -X $method http://$SERVER/$path -H "X_APP: $APPKEY,$APPPASSWD" $file 2>&1
}

function assert_result()
{
    grep -E '< HTTP|< ETag' |sed 's/\r//g' |gawk '{print $1,$2,$3}'| gawk '
/HTTP/{status = $3;}
/ETag/{etag = $3;}
END{if(status=="'"$1"'" && etag=="'"$2"'")
{print "PASS";}
else
{printf("FAIL ret_status=%s expect_status=%s ret_etag=%s expect_etag=%s\n",
status, "'"$1"'", etag, "'"$2"'");}
}'
}

function test_picfile()
{
    picid=$1
    picfile=$2

    # clean up
    request "DELETE" "pic/file/$picid" > /dev/null

    request "GET" "pic/file/$picid" | assert_result 404 $picid
    request "DELETE" "pic/file/$picid" | assert_result 404 $picid
    request "POST" "pic/file/new" "$picfile" | assert_result 201 $picid
    request "POST" "pic/file/new" "$picfile" | assert_result 200 $picid
    request "GET" "pic/file/$picid" | assert_result 200 $picid
    request "DELETE" "pic/file/$picid" | assert_result 200 $picid
    request "GET" "pic/file/$picid" | assert_result 404 $picid
    request "DELETE" "pic/file/$picid" | assert_result 404 $picid    
}

function test_picinfo()
{
    picid=$1
    picinfofile=$2

    # clean up
    request "DELETE" "pic/info/$picid" > /dev/null

    request "GET" "pic/info/$picid" | assert_result 404 $picid
    request "DELETE" "pic/info/$picid" | assert_result 404 $picid
    request "POST" "pic/info/$picid" "$picinfofile" | assert_result 201 $picid
    request "POST" "pic/info/$picid" "$picinfofile" | assert_result 200 $picid
    request "GET" "pic/info/$picid" | assert_result 200 $picid
    request "DELETE" "pic/info/$picid" | assert_result 200 $picid
    request "GET" "pic/info/$picid" | assert_result 404 $picid
    request "DELETE" "pic/info/$picid" | assert_result 404 $picid    
}

function runpicfile()
{
    curdir=`dirname $0`
    for file in `ls $curdir/*.png $curdir/*.jpg`;
    do
        echo ">> running at $file <<"
        picid=`basename $file | cut -d. -f1`
        test_picfile $picid $file
    done
}

function runpicinfo()
{
    curdir=`dirname $0`
    for file in `ls $curdir/*.info`;
    do
        echo ">> running at $file <<"
        picid=`basename $file | cut -d. -f1`
        test_picinfo $picid $file
    done
}

function loadpicfile()
{
    curdir=`dirname $0`
    for file in `ls $curdir/*.png $curdir/*.jpg`;
    do
        echo ">> running at $file <<"
        picid=`basename $file | cut -d. -f1`
        request "POST" "pic/file/new" $file
    done
}

function loadpicinfo()
{
    curdir=`dirname $0`
    for file in `ls $curdir/*.info`;
    do
        echo ">> running at $file <<"
        picid=`basename $file | cut -d. -f1`
        request "POST" "pic/info/$picid" $file
    done
}

if [ $# -eq 0 ];
then
    printf "test.sh <runpicfile|runpicinfo|loadpicfile|loadpicinfo>\n"
    exit
fi

$1 "$2" "$3"

