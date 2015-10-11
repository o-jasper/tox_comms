--  Copyright (C) 07-08-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

-- Just stripping the preceeding `tox_` at the moment.

local ffi = require "ffi"
local raw = require "ffi.tox.raw"

local plain_funlist = {
   "version_major",
   "version_minor",
   "version_patch",
   "version_is_compatible",
   "options_new",
   "new",
}

local opts_funlist = {
   options_default = false,
   options_free = false,   
}

local Public = { raw=raw, Tox=require "ffi.tox.Tox", Opts={} }

Public.Opts.__index = Public.Opts

function Public.options_new(err)
   return setmetatable({ cdata = raw.tox_options_new(err) }, Public.Opts), err
end
Public.Opts.new = Public.options_new

return Public
