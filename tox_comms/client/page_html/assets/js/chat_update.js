var fa = "{%fa}"
var ta = "{%ta}"

function chat_update() {
    var list = list_events_all(fa, ta)

    if( list.length == undefined ) {
        ge("cnt").textContent = 0;
    } else {
        ge("cnt").textContent = list.length;
    }

    var html = "<table>";
    for( i in list) {
        var el = list[i];
        var lhtml = "<tr><td>" + el[0] + ":</td><td><small>" + el[1] + "</small></td>";
        for( j in el[3] ){
            lhtml = lhtml + "<td>" + el[3][j] + "</td>";
        }
        html = html + lhtml + "</tr>";
    }
    ge("list").innerHTML = html + "</table>";
}
