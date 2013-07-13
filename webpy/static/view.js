
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
    document.location.href="/masonry.html";
}
else
{
    imgurl = "/pic/file/" + pic;
    var img=document.createElement("img");
    $(img).attr("src", imgurl);

    page_str = ""
    if(ret_page > 1)
    {
        page_str="?p=" + ret_page;
    }

    var a=document.createElement("a");
    $(a).attr("href", "/masonry.html"+page_str)
        .append(img);

    $("#imgviewer>div").append(a);
    $("#prevpage").attr('href', "/masonry.html"+page_str);
}

