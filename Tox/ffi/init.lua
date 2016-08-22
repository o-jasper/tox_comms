-- TODO what is the role?

--  Copyright (C) 22-08-2016 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

-- Just stripping the preceeding `tox_` at the moment.

local ffi = require "ffi"
local raw = require "Tox.ffi.raw"

local plain_funlist = {
   "version_major",
   "version_minor",
   "version_patch",
   "version_is_compatible",
   "options_new",
}

local opts_funlist = {
   options_default = false,
   options_free = false,   
}
local Public = { Opts={}, } --Tox = require "Tox.ffi.Tox" }

for _, k in pairs(plain_funlist) do
   local v = raw["tox_" .. k]
   if v then
      Public[k] = v
   else
      print("MISSING", "tox_" .. k)
   end
end

Public.Opts.__index = Public.Opts

function Public.options_new(err)
   return setmetatable({ cdata = raw.tox_options_new(err) }, Public.Opts), err
end
Public.Opts.new = Public.options_new

return Public
