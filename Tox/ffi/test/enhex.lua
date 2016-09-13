local to_c = require "Tox.ffi.to_c"

local hex = arg[1]
assert(to_c.enhex(to_c.bin(hex), #hex/2) == hex)
