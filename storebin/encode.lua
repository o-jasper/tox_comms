local floor, abs = math.floor, math.abs

local encode_uint = require "tox_comms.storebin.encode_uint"

--local function encode_int(fd, x)
--   encode_uint((x<2 and 1 or 0) + 2*x)
--end

local function submerge(x)
   return math.ceil(math.log(x)/math.log(2))
end

local function encode_float(fd, data)
   local x = abs(data)
   local sub = submerge(x)
   local y = floor(x*2^(63-sub))

   encode_uint(fd, (data < 0 and 4 or 3) + 8*(sub < 1 and 1 or 0) + 16*abs(sub))
   encode_uint(fd, y)
end

-- 0 string
-- 1 integer - positive
-- 2 integer - negative
-- 3 float - positive
-- 4 float - negative
-- 6 table - without metatable.
-- 7 table - with metatable `:name_it` is to name the metatable.

local encoders = {}

local function encode(fd, data)
   encoders[type(data) or "nil"](fd, data)
end

encoders = {
   string = function(fd, data)
      assert(type(data) == "string")
      encode_uint(fd, 0 + 8*#data)
      fd:write(data)
   end,

   number = function(fd, data)
      if data%1 == 0 then -- Integer
         if data < 0 then
            encode_uint(fd, 2 - 8*data)
         else
            encode_uint(fd, 1 + 8*data)
         end
      elseif data then
         encode_float(fd, data)
      end
   end,

   table = function(fd, data)
      local cnt = 0
      for k,v in pairs(data) do
         if type(k) ~= "function" and type(v) ~= "function" then
            cnt = cnt + 1
         end
      end
      if getmetatable(data) then
         encode_uint(fd, 7 + 8*cnt)
         -- Put in the name too.
         local name = type(data.metatable_name) == "function" and data:metatable_name() or ""
         assert(type(name) == "string")
         encode_uint(fd, #name)
         fd:write(name)
      else
         encode_uint(fd, 6 + 8*cnt)
      end
      for k,v in pairs(data) do
         if type(k) ~= "function" and type(v) ~= "function" then
            encode(fd, k)
            encode(fd, v)
         end
      end
   end,

   boolean = function(fd, data) encode_uint(fd, 5 + 8*(data and 0 or 1)) end,

   ["nil"] = function(fd) encode_uint(fd, char(5 + 8*2)) end,
   
   ["function"] = function(fd) encode_uint(fd, 5 + 8*3) end,

   userdata = function(fd) encode_uint(fd, 5 + 8*4) end,

   thread = function(fd) encode_uint(fd, 5 + 8*5) end,
}

return encode
