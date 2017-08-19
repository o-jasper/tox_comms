local ffi = require "ffi"

ffi.cdef(require "Tox.ffi.events.api")

return ffi.load(os.getenv("HOME") .. "/.lualibs/Tox/ffi/events/ToxEvents.so")
--Tox.ffi.events.ToxEvents")
