function touch_claim_input(event, fa, name, id, bid) {
    if(event && event.keyCode == 13) { do_claim(fa, name, id, bid); }
}

function do_claim(fa, name, id, bid) {
    var pre_te = ge("bid").textContent;
    ge(bid).textContent = "Processing"

    var cb = function() {
        ge(bid).textContent = pre_te;
        ge(id).value = null;
    }
    callback_alias_set_claim([fa, name, ge(id).value], cb);
}
