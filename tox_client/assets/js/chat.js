var touched_since = false;

function touch_chat_input() { touched_since = true; }

function send_chat_input_cb() {
    ge("chat_input_button").textContent = "s";
    if(!touched_since){ ge("chat_input").value = ""; }
    chat_update(); 
    touched_since = false;
}

//var send_delay = 1; // Might want delaying option.
function send_chat_input() {
    touched_since = false;
    ge("chat_input_button").textContent = "U";
    callback_send_chat([fa, ta, 0, ge("chat_input").value], send_chat_input_cb);
}
