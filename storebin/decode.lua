local floor = math.floor

local decode_uint = require "tox_comms.storebin.decode_uint"

local function decode_positive_float(read, top)
   local y = decode_uint(read)
   local sub = ((top%2 == 0) and 1 or -1) * floor(top/2)
   return y*2^(sub-63)
end

local decoders = {}

local function decode(read, meta_fun)
   local top = decode_uint(read)
   return decoders[top%8](read, floor(top/8), meta_fun or {})
end

local function decode_table(read, cnt)
   local list_cnt = decode_uint(read)
   local ret = {}
   for _ = 1,list_cnt do
      table.insert(ret, decode(read))
   end
   for _ = 1,cnt do
      local key = decode(read)
      ret[key]  = decode(read)
   end
   return ret
end

decoders = {
   [0] = function(read, len)  -- String.
      return read(len)
   end,
   [1] = function(_, number)  -- Positive integer.
      return number
   end,
   [2] = function(_, positive)  -- Negative integer.
      return -1 * positive
   end,
   [3] = decode_positive_float,
   [4] = function(read, top)  -- Negative float.
      return -1 * decode_positive_float(read, top)
   end,
   
   [5] = function(read, which)  -- Boolean, nil, other.
      return ({true, false, nil})[1+ which]
   end,
   
   [6] = decode_table,
   [7] = function(read, cnt, meta_fun)  -- Table.
      local name_len = decode_uint(read)
      local name = read(name_len)
      local ret = decode_table(read, cnt)
      return meta_fun[key] and meta_fun[key](ret) or ret
   end,
}

return decode
