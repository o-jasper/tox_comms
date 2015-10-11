--  Copyright (C) 07-08-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local libfile  = "toxcore" --"/usr/lib/libtoxcore.so"  -- TODO locate them better.

if globals then
   local config = globals.ffi_tox or {}
   libfile  = config.libfile  or libfile
end

-- The inbuild stuff from luajit.. So it requires luajit at the moment!
local ffi = require("ffi")

assert(ffi, [[Need `require "ffi"` to work, luajit has it inbuild, lua afaik not.]])

-- NOTE: how it works seems bad style. Something in the _global_ state from
-- ffi.cdef goes into the lib somehow.
ffi.cdef(require "tox_comms.ffi.tox_api")
local lib = ffi.load(libfile)

return lib
