
var picfixwidth=300


function load_pic(arr)
{
    //container = document.getElementById("container");

    var items=[];
    n=arr.length;
    for(i=0; i<n; ++i)
    {
        info=arr[i];

        var img=document.createElement("img");
        $(img).attr("src", "/pic/file/" + info.picid + "." + info.picformat.toLowerCase())
            .attr("title", info.picname)
            .attr("alt", info.picname)
            .attr("width", picfixwidth + "px")
            .attr("height", Math.round(info.picwidth * picfixwidth / info.picheight) + "px");

        var a=document.createElement("a");
        $(a).attr("href", "/pic/file/" + info.picid + "." + info.picformat.toLowerCase());

        var title=document.createElement("p");
        $(title).html(info.picname);

        var item=document.createElement("div");
        $(item).addClass("item");

        a.appendChild(img);
        //a.appendChild(title);
        item.appendChild(a);

        items.push(item);

        //$('#container').masonry()
            //.append(item)
            //.masonry('appended', item)
            //.delay(1000)
            //.masonry();
        //container.appendChild(item);
        //masonry.appended(item);
        //masonry.layout();
    }

    window.setTimeout(function(){
        for(i=0; i<n; ++i)
        {
            $('#container').masonry()
                .append(items[i])
                .masonry('appended', items[i])
                .masonry();
        }
    },
                      00);
}


function exejson(jsonurl)
{
    s=document.createElement("script");
    s.setAttribute("src", jsonurl);
    s.setAttribute("type", "text/javascript");
    document.head.appendChild(s);
}

var cur_page=0;
var num_per_page=20;

function load_next_page()
{
    jsonurl="/pic/info/list/" + cur_page + "/" + num_per_page + "?callback=load_pic";
    exejson(jsonurl);
    cur_page += num_per_page;
}

function set_next_page()
{
    nexturl="/pic/info/list/" + cur_page + "/" + num_per_page;
    $("a#more:last").attr('href',nexturl);
}

load_next_page();
