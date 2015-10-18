function touch_chat_input(event) {
    if(event && event.keyCode == 13) {
        send_chat_input();
    }
}

function send_chat_input_cb() {
    ge("chat_input_button").textContent = "s";
    chat_update(); 
}

var send_delay = false; // Might want delaying option.
function send_chat_input(dont_delay) {
    if(!send_delay || dont_delay) {
        ge("chat_input_button").textContent = "U";
        callback_send_chat([fa, ta, 0, ge("chat_input").value], send_chat_input_cb);
        ge("chat_input").value = "";
    } else {
        // TODO delay only really useful if you can cancel..
        ge("chat_input_button").textContent = "W " + send_delay/1000 + "s";
        setTimeout(function(){ send_chat_input(true); }, send_delay);
    }
}
