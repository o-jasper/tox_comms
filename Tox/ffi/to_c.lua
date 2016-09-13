--  Copyright (C) 22-08-2016 Jasper den Ouden.
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
      local x = string.find("0123456789ABCDEF", string.sub(str, i,i), 0, true)
      local y = string.find("0123456789ABCDEF", string.sub(str, i + 1,i + 1), 0, true)
      assert(x and y, string.format("Not good; %s\n%s", string.sub(str, i, i + 1), str))
      table.insert(ret, 16*(x - 1) + y - 1)
      i = i + 2
   end
   return ret
end

Public.dehex = dehex

local function hex_char(i)
   return string.sub("0123456789ABCDEF", i,i)
end

function Public.enhex(arr, sz)
   local ret = ""
   for i = 1, sz do
      local el = arr[i - 1] or string.byte(arr, i)
      ret = ret .. hex_char(1 + math.floor(el/16)) .. hex_char(1 + el%16)
   end
   return ret
end

-- Hex to binary version thereof.
function Public.bin(bin)
   if type(bin) == "cdata" then
      return bin
   end
   bin = (type(bin) == "string" and dehex(bin)) or bin
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

-- String to binary version of string.
function Public.str(str, tp)
   assert(type(str) == "string",
          string.format("String to create not a string, but %s (%s)", type(str), str))
   local i, ret = 0, ffi.new(tp or "uint8_t[?]", #str + 1)
   while i < #str do
      ret[i] = string.byte(str, i + 1)
      i = i + 1
   end
   ret[i] = string.byte("\0")
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
