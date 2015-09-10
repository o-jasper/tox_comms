# Tox bot

Does commands and provides start for handling friends and stuff.

Stores stuff via
[storebin](https://github.com/o-jasper/tox_comms/tree/master/storebin).
Not using `:save`, redefining `Bot.use_file_encode`, `Bot.use_file_decode`
can remove the dependency.
(`false` turns them off, `:save` with cause error then)

Running can be done with `luajit main.lua`, argument is a tox address it'll
contact. Suggest contacting yourself. Only `luajit` here afaik.

### TODO
* General idea of comms, not tox particular?
