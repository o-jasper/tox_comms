local storebin = require "mybot.storebin"


local tab = {1,2,4, 7.5,{},true,false,nil, sub={q=1,r="ska"}, ska=43}

local json = require "json"

print("---encode---")
local fd = io.open("/tmp/lua_b", "wb")
fd:write(json.encode(tab))
fd:close()

local file = "/tmp/lua_a"
print("---encode---")
local fd = io.open(file, "wb")
storebin.encode(fd, tab)
fd:close()

print("---decode---")
local fd = io.open(file, "rb")
local tab2 = storebin.decode(fd)
fd:close()
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
