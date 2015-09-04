local serial = require "tox_comms.storebin.file"

local tab = {1,2,4, 7.5,{},true,false,nil, sub={q=1,r="ska", 1/0,-1/0}, ska=43}

local file = "/tmp/lua_a"
print("---encode---")
serial.encode(file, tab)

print("---decode---")
local tab2 = serial.decode(file)
print(tab, tab2)

local function assert_eq(a, b)
   assert(type(a) == type(b), string.format("%s ~= %s", a,b))
   if type(a) == "table" then
      for k,v in pairs(a) do
         assert_eq(v, b[k])
      end
   else
      assert(a == b, string.format("%s ~= %s", a,b))
   end
end

assert_eq(tab, tab2)
assert_eq(tab2, tab)
