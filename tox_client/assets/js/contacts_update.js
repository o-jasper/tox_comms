var fa = "{%fa}"

function contacts_update() {
    var ret = contact_html_list(fa, {"html_list":true});

    ge("cnt").textContent = ret.cnt;

    var html = "<table>";
    var list = ret.html_list;
    for( i in list ){ html = html + list[i]; }
    ge("list").innerHTML = html + "</table>";
}
