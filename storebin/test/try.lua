local storebin = require "mybot.storebin"

local file = os.tmpname()

local tab = {1,2,4, 7.5,{},true,false,nil, sub={q=1,r="ska"}, ska=43}

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
   assert(type(a) == type(b))
   if type(a) == "table" then
      for k,v in pairs(a) do
         assert_eq(v, b[k])
      end
   else
      assert(a == b, string.format("%s ~= %s", a,b))
   end
end

assert_eq(tab, tab2)
