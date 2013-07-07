
function load_pic(arr)
{
    container = document.getElementById("container");
    n=arr.length;

    for(i=0;i<n; ++i)
    {
        info=arr[i];

        content=document.createElement("div");
        content.setAttribute("class", "content");
        
        div=document.createElement("div");
        
        a=document.createElement("a");
        a.setAttribute("href", "/pic/file/" + info.picid + "." + info.picformat.toLowerCase());

        img=document.createElement("img");
        img.setAttribute("src", "/pic/file/" + info.picid + "." + info.picformat.toLowerCase());
        img.setAttribute("title", info.picname);
        img.setAttribute("alt", info.picname);
        img.setAttribute("class", "thumb");

        a.appendChild(img);
        div.appendChild(a);
        content.appendChild(div);

        container.appendChild(content);


        // h3=document.createElement("h3");
        // h3.innerText=info.picname;
        // article=document.createElement("article");
        // article.appendChild(h3);
        // img=document.createElement("img");
        // img.setAttribute("src", "/pic/file/" + info.picid + "." + info.picformat.toLowerCase());
        // article.appendChild(img);
        // container.appendChild(article);
    }

    delayload();
}


function exejson(jsonurl)
{
    s=document.createElement("script");
    s.setAttribute("src", jsonurl);
    s.setAttribute("type", "text/javascript");
    document.head.appendChild(s);
}

cur_page=0;
num_per_page=10;

function load_next_page()
{
    jsonurl="/pic/info/list/" + cur_page + "/" + num_per_page + "?callback=load_pic";
    exejson(jsonurl);
    cur_page += num_per_page;
}

load_next_page();
