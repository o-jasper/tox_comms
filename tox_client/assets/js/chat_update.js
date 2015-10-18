var fa = "{%fa}", ta = "{%ta}";
var after_time = 0, ret_cnt = 0;

function chat_update_cb(ret) {
    after_time = ret.last_time;
    ret_cnt += ret.cnt;

    ge("cnt").textContent = ret_cnt;

    var list_el = ge("list");
    // List of stuff added at the end.
    var html_list = ret.html_list;
    for( i in html_list ){
        var el = document.createElement("tr");
        el.id = html_list[i].id;
        el.innerHTML = html_list[i].html;
        list_el.appendChild(el)
    }
    ge("chat_input_button").textContent = "S";
}

function chat_update() {
    // TODO use the callback, of course.
    callback_chat_html_list([fa, ta, {"html_list":true, "after_time":after_time}],
                            chat_update_cb);
}
