var fa = "{%fa}"

function contacts_update() {
    var list = contacts_more(fa);  // Contacts with the extra information.

    if( list.length == undefined ) {
        ge("cnt").textContent = 0;
    } else {
        ge("cnt").textContent = list.length;
    }

    var html = "<table>";
    for( i in list ){
        var el = list[i];
        var lhtml = "<tr><td>" + el[0] + ":</td><td>" + el[1].name + "</td></tr>" +
            "<tr><td colspan=2>" + el[1].status_message + "</td></tr>";
        html = html + lhtml;
    }
    ge("list").innerHTML = html + "</table>";
}
