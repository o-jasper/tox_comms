function contacts_update_cb(ret) {
    ge("cnt").textContent = ret.cnt;

    var html = ""
    var list = ret.html_list;
    for( i in list ){ html = html + "<tr>" + list[i].html + "</tr>"; }
    ge("list").innerHTML = html;
}

function contacts_update() {
    ge("cnt").textContent = "X";
    callback_contact_html_list([fa, {"html_list":true}], contacts_update_cb);
}
