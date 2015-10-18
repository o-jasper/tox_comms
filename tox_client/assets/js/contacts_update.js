var fa = "{%fa}"

function contacts_update() {
    var ret = contact_html_list(fa, {"html_list":true});

    ge("cnt").textContent = ret.cnt;

    var html = ""
    var list = ret.html_list;
    for( i in list ){ html = html + "<tr>" + list[i].html + "</tr"; }
    ge("list").innerHTML = html;
}
