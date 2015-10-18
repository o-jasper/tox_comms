var fa = "{%fa}"
var ta = "{%ta}"

function chat_update() {
    var ret = chat_html_list(fa, ta, {"html_list":true});

    ge("cnt").textContent = ret.cnt;

    var html = "<table>";
    var list = ret.html_list;
    for( i in list ){ html = html + list[i]; }
    ge("list").innerHTML = html + "</table>";
}
