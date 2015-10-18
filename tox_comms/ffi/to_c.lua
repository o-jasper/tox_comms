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

Public.dehex = dehex

function Public.enhex(arr, sz)
   local ret = ""
   for i = 1, sz do
      local el = arr[i - 1] or string.byte(arr, i)
      local x, y = 1 + el%16, 1 + math.floor(el/16)
      ret = ret .. string.sub("0123456789ABCDEF", y,y) .. string.sub("0123456789ABCDEF", x,x)
   end
   return ret
end

function Public.bin(bin)
   if type(bin) == "cdata" then
      return bin
   end
   bin = type(bin) == "string" and dehex(bin) or bin
   local ret = ffi.new("uint8_t[?]", #bin)
   for j, v in ipairs(bin) do ret[j - 1] = v end
   return ret
end

function Public.addr(addr)
   if type(addr) == "cdata" then
      return addr
   end
   addr = type(addr) == "string" and dehex(addr) or addr
   local ret = ffi.new("uint8_t[38]")
   for j, v in ipairs(addr) do ret[j - 1] = v end
   return ret
end

function Public.str(str, tp)
   assert(type(str) == "string",
          string.format("String to create not a string, but %s (%s)", type(str), str))
   local i, ret = 0, ffi.new(tp or "uint8_t[?]", #str)
   while i < #str do
      ret[i] = string.byte(str, i + 1)
      i = i + 1
   end
   return ret
end

-- Produces a function that converts gets out&converts the return string.
function Public.ret_via_arg(name, ctp, rawname, szname)
   local rawname = rawname or "_" .. name
   local szname  = szname  or "_" .. name .. "_size"
   local ctp = ctp or "char[?]"
   return function(self)
      local sz = self[szname](self)
      local ret = ffi.new(ctp, sz)
      self[rawname](self, ret)
      return ffi.string(ret, sz)
   end
end

function Public.ret_via_args_no_size(name, ctp, rawname, sz)
   local rawname = rawname or "_" .. name
   local ctp = ctp or "uint8_t[32]"
   return function(self)
      local ret = ffi.new(ctp)
      self[rawname](self, ret)
      if sz then
         return ffi.string(ret, sz)
      else
         return ret
      end
   end
end

return Public
