var force_show = false
function force_toggle() { force_show = !force_show; show_new_message_area(force_show); }

function show_new_message_area(to) {
    ge('new_message_area').hidden = !to;
    ge("force_toggle").textContent = force_show ? "H" : "S";
}

function touch_addr_input(event) {
    show_new_message_area(ge("new_addr_input").value.length >= 64);

    if(event && event.keyCode == 13) {
        show_new_message_area(true);
        ge("new_message_input").focus();
    }
}

function touch_message_input(event) {
    if(event && event.keyCode == 13) {
        do_add_contact();
    }
}

function do_add_contact() {
    var cb = function(){
        contacts_update();
        ge("new_addr_input").value    = "";
        ge("new_message_input").value = "";
    }
    callback_add_contact([fa, ge("new_addr_input").value, ge("new_message_input").value], cb);
}
