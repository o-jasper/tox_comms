--  Copyright (C) 07-08-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local ffi = require "ffi"

local Public = {}

local function dehex(str)
   local i, ret = 1, {}
   while i < #str do
      local x = string.find("0123456789ABCDEF", string.sub(str, i,i), 0, true) - 1
      local y = string.find("0123456789ABCDEF", string.sub(str, i + 1,i + 1), 0, true) - 1
      local here = 16*x + y
      table.insert(ret, here)
      i = i + 2
   end
   return ret
end

function Public.addr(addr)
   if type(addr) == "cdata" then
      return addr
   end
   addr = type(addr) == "string" and dehex(addr) or addr
   local ret = ffi.new("uint8_t[38]")
   for j, v in pairs(addr) do ret[j - 1] = v end
   return ret
end

function Public.str(str)
   assert(type(str) == "string")
   local i, ret = 0, ffi.new("uint8_t[?]", #str + 1)
   while i < #str do
      ret[i] = string.byte(str, i + 1)
      i = i + 1
   end
   ret[#str] = 0
   return ret
end

-- Produces a function that converts gets out&converts the return string.
function Public.ret_via_arg(name, ctp, rawname, szname)
   local rawname = rawname or "_" .. name
   local szname  = szname  or name .. "_size"
   local ctp = ctp or "char[?]"
   return function(self)
      local sz = self[szname](self)
      local ret = ffi.new(ctp, sz)
      self[rawname](self, ret)
      return ffi.string(ret, sz)
   end
end

function Public.ret_via_args_no_size(name, ctp, rawname)
   local rawname = rawname or "_" .. name
   local ctp = ctp or "uint8_t[32]"
   return function(self)
      local ret = ffi.new(ctp)
      self[rawname](self, ret)
      return ret
   end
end

return Public
