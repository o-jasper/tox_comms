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

decoders = {
   [0] = function(fd, top)  -- String.
      return fd:read(top)
   end,
   [1] = function(_, top)  -- Positive integer.
      return top
   end,
   [2] = function(_, top)  -- Negative integer.
      return -1 * top
   end,
   [3] = decode_positive_float,
   [4] = function(fd, top)  -- Negative float.
      return -1 * decode_positive_float(fd, top)
   end,
   
   [5] = function(fd, top)  -- Boolean, nil, other.
      return ({true, false, nil})[1+ top]
   end,
   
   [6] = function(fd, top)  -- Table.
      local ret, cnt = {}, top
      for _ = 1,cnt do
         local key = decode(fd)
         ret[key] = decode(fd)
      end
      return ret
   end,
   [7] = function(fd, top, meta_fun)  -- Table.
      local ret, cnt = {}, top
      local name = fd:read(decode_uint(fd))
      for _ = 1,cnt do
         local key = decode(fd)
         ret[key]  = decode(fd)
      end
      return meta_fun[key] and meta_fun[key](ret) or ret
   end,
}

return decode
