local floor, abs = math.floor, math.abs

local encode_uint = require "tox_comms.storebin.encode_uint"

local function submerge(x)
   return math.ceil(math.log(x)/math.log(2))
end

local function encode_float(write, data)
   local x = abs(data)
   local sub = submerge(x)
   local y = floor(x*2^(63-sub))

   encode_uint(write, (data < 0 and 4 or 3) + 8*(sub < 1 and 1 or 0) + 16*abs(sub))
   encode_uint(write, y)
end

-- 0 string
-- 1 integer - positive
-- 2 integer - negative
-- 3 float - positive
-- 4 float - negative
-- 6 table - without metatable.
-- 7 table - with metatable `:name_it` is to name the metatable.

local encoders = {}

local function encode(write, data)
   encoders[type(data) or "nil"](write, data)
end

local not_key = { ["nil"]=true, ["function"]=true, userdata=true, thread=true }

encoders = {
   string = function(write, data)
      assert(type(data) == "string")
      encode_uint(write, 0 + 8*#data)
      write(data)
   end,

   number = function(write, data)
      if data%1 == 0 then -- Integer
         if data < 0 then
            encode_uint(write, 2 - 8*data)
         else
            encode_uint(write, 1 + 8*data)
         end
      elseif data then
         encode_float(write, data)
      end
   end,

   table = function(write, data)
      local i, got = 1, {}  -- Figure out what goes in the list.
      if data[i] ~= nil or data[i+1] ~= nil or data[i+2] ~=nil then
         while data[i] ~= nil or data[i+1] ~= nil or data[i+2] ~=nil do
            got[i] = true
            i = i + 1
         end
         while data[i] == nil do i = i - 1 end
      end
      local cnt = 0
      for k,v in pairs(data) do
         if not (not_key[k] or got[k]) then
            cnt = cnt + 1
         end
      end
      if getmetatable(data) then
         encode_uint(write, 7 + 8*cnt)
         -- Put in the name too.
         local name = type(data.metatable_name) == "function" and data:metatable_name() or ""
         assert(type(name) == "string")
         encode_uint(write, #name)
         write(name)
      else
         encode_uint(write, 6 + 8*cnt)
      end
      encode_uint(write, i)  -- Feed the list.
      for j = 1,i do
         encode(write, data[j])
      end
      
      for k,v in pairs(data) do
         if not (not_key[k] or got[k]) then
            encode(write, k)
            encode(write, v)
         end
      end
   end,

   boolean = function(write, data) encode_uint(write, 5 + 8*(data and 0 or 1)) end,

   ["nil"] = function(write) encode_uint(write, 5 + 8*2) end,
   
   ["function"] = function(write) encode_uint(write, 5 + 8*3) end,

   userdata = function(write) encode_uint(write, 5 + 8*4) end,

   thread = function(write) encode_uint(write, 5 + 8*5) end,
}

return encode
