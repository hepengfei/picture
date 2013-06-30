
APPKEY="me"
APPPASSWD="aa"

VERBOSE="-v"

SERVER="benben:8080"

function request()
{
    method=$1
    path=$2
    file=$3
   
    if ! [ -z $file ];
    then
        file="-T $file"
    fi
    curl $VERBOSE -X $method http://$SERVER/$path -H "X_APP: $APPKEY,$APPPASSWD" $file
}

function post()
{
    request "POST" "pic/file/new" "test1.png" 
}

function get()
{
    request "GET" "pic/file/$1"
}

function delete()
{
    request "DELETE" "pic/file/$1"
}

