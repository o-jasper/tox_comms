
function aliasses_update_cb(addrs) {
    ge("cnt").textContent = addrs.length;

    var html = "<table>"
    for(i in addrs) {  // TODO claims of self?
        html = html + '<tr><td><a href="/contacts/' + addrs[i] + '">' + 
            addrs[i] + '</a></td></tr>';
    }
    ge("list").innerHTML = html + "</table>";    
}
function aliasses_update() {
    callback_tox_addrs([], aliasses_update_cb);
}
