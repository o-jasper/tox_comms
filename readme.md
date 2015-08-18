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

## TODO

* Better Tox channel creation.
  + use other things than the message sending. Like the file sending or
    lossless packets.(just redefine `:send_chunk`)
  + (more speed)Perhaps write more of it in C.
  + (more bandwidth efficient) better data encoding that json.
