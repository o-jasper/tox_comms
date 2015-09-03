local floor = math.floor

local decode_uint = require "tox_comms.storebin.decode_uint"

local function decode_positive_float(fd, top)
   local y = decode_uint(fd)
   local sub = ((top%2 == 0) and 1 or -1) * floor(top/2)
   return y*2^(sub-63)
end

local decoders = {}

local function decode(fd, meta_fun)
   local top = decode_uint(fd)
   return decoders[top%8](fd, floor(top/8), meta_fun or {})
end

local function decode_table(fd, cnt)
   local ret = {}
   for _ = 1,cnt do
      local key = decode(fd)
      ret[key]  = decode(fd)
   end
   return ret
end

decoders = {
   [0] = function(fd, len)  -- String.
      return fd:read(len)
   end,
   [1] = function(_, number)  -- Positive integer.
      return number
   end,
   [2] = function(_, positive)  -- Negative integer.
      return -1 * positive
   end,
   [3] = decode_positive_float,
   [4] = function(fd, top)  -- Negative float.
      return -1 * decode_positive_float(fd, top)
   end,
   
   [5] = function(fd, which)  -- Boolean, nil, other.
      return ({true, false, nil})[1+ which]
   end,
   
   [6] = decode_table,
   [7] = function(fd, cnt, meta_fun)  -- Table.
      local name_len = decode_uint(fd)
      local name = fd:read(name_len)
      local ret = decode_table(fd, cnt)
      return meta_fun[key] and meta_fun[key](ret) or ret
   end,
}

return decode
