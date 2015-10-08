# Tox communications.

`Tox.lua` ports tox into an object, `ToxFriend` is everything regarding friends
about that. These two have functions analogous to tox's functionality.

Then `ToxChannelMsg` uses messages to build channels ontop. Bare channels have:
(the definition evolved a bit as i wrote it)

* `:channel_data(name, data)` sends data to the friend on that name.
* `.data_cb={...}` contains the callbacks, by `name`, that are run when a message
  arrives completely. Arguments are `(self, nr, data)`.
  
Ontop of that, only minorly differently as originally;

* `:call(name, return_callback)(...)` returns the function that you can put
  the arguments in which will are called on the friend side.
  
  I works by using `:channel_data` with `"json_call"` to call it a function
  on the other end, which then uses `"json_ret"` to return the result, if
  the function is marked as returnable. `data_cb.json_ret` will use the
  `return_callback` with the data.

## Chat

Initially, to my annoyance, i wrote something too tied to Tox. In future
strive for API:

* `:ensure_edge(from_addr, to_addr)` &rarr; `e` an edge between those two users.
  If you control the `from_addr`, then it sends data.

  if you control the `to_addr` it pretend-sends it.

* `:block(from_addr, [to_addr])` set that to false, blocking it.

Then from the edge:

* `e:see_claim(i, name, ...)` information received from contact claiming:
  `e.allow_claims` indicate which are allowed, default:
  + `"name"`, main name, followed by single name
  + `"status_message"` Status message
* `e:see_msg(i, kind, message)` receive a message.
* `e:see_friend_request(i, message)` friend request.
* `e:see_missed(i, fi, ti)` claim range of messages missed.

* `e:do_claim` and `e:do_msg` are the active versions, you call these, and
  they do do the acts, or return `true` for inability.

* `e.name` is the name to actually use. `e.request_name` is requested one,
  if not accepted/denied.
* `e.claims` contains current claims.
* `e.history` history claims.

## TODO

* File sending didnt work?

* Better Tox channel creation.
  + use other things than the message sending. Like the file sending or
    lossless packets.(just redefine `:send_chunk`)
  + Use "something that looks like the `require "json"` package rather than
    json. I.e. make those like [storebin](https://github.com/o-jasper/storebin)
    an option.

## Lua Ring

* [lua_Searcher](https://github.com/o-jasper/lua_Searcher) sql formulator including
  search term, and Sqlite bindings.

* [page_html](https://github.com/o-jasper/page_html) provide some methods on an object,
  get a html page.(with js)

* [storebin](https://github.com/o-jasper/storebin) converts trees to binary, same
  interfaces as json package.(plus `file_encode`, `file_decode`)
  
* [PegasusJs](https://github.com/o-jasper/PegasusJs), easily RPCs javascript to
  lua. In pegasus.

* [tox_comms](https://github.com/o-jasper/tox_comms/), lua bindings to Tox and
  bare bot.
