
function get_picid(url){
    var r=url.match(/^.*[&?]id=([0-9a-zA-Z._]+)/)
    if(r && r.length == 2)
    {
        return  r[1];
    }
    return false;
}

function get_cur_page(url){
    p = 0;
    var r=url.match(/^.*[&?]p=([0-9]+)/)
    if(r && r.length == 2)
    {
        p = Number(r[1])
    }
    if(p == 0)
    {
        p = 1;
    }
    return p;
}


pic=get_picid(document.location.href)
ret_page=get_cur_page(document.location.href)

if(pic == false)
{
    document.location.href="/";
}
else
{
    var imgurl = "/pic/file/" + pic;
    var img=document.createElement("img");
    $(img).attr("src", imgurl);

    page_str = ""
    if(ret_page > 1)
    {
        page_str="?p=" + ret_page;
    }

    var a=document.createElement("a");
    $(a).attr("href", "/"+page_str)
        .append(img);

    $("#imgviewer>div").append(a);
    $("#prevpage").attr('href', "/"+page_str);
}


url = "/pic/info/series/" + pic.substr(0,32) + "?callback=loadseries"

function exejson(jsonurl)
{
    s=document.createElement("script");
    s.setAttribute("src", jsonurl);
    s.setAttribute("type", "text/javascript");
    document.head.appendChild(s);
}

function loadseries(data)
{
    var n=data.length;
    for(i=0;i<n;++i)
    {
        if(data[i]["picid"] == pic.substr(0,32))
            continue;

        var imgurl = "/pic/file/" + data[i]["picid"]  + "." + data[i].picformat.toLowerCase();
        var img=document.createElement("img");
        $(img).attr("src", imgurl)
        .attr("alt", data[i]["picname"]);
        
        var a=document.createElement("a");
        $(a).attr("href", "/"+page_str)
            .append(img);
        
        var div=document.createElement("div");
        $(div).append(a);

        var art=document.createElement("article");
        $(art).attr("id", "imgviewer")
            .append(div);

        $("#imgviewer:last").after(art);
    }

}

exejson(url)


