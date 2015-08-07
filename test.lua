local Tox = require "Tox"

local comm = Tox.new({})

local function hexify(list, n)
   local hex = "0123456789ABCDEF"
   local i, n, ret = 0, n or #list, ""
   while i < n do
      local k, l = math.floor(list[i]/16) + 1, list[i]%16 + 1
      ret = ret .. string.sub(hex, k, k) .. string.sub(hex, l, l)
      i = i + 1
   end
   return ret
end

print(hexify(comm:self_get_address(), 38))

print(comm:bootstrap("54.199.139.199",
                     33445, "951C88B7E75C867418ACDB5D273821372BB5BD652740BCDF623A4FA293E75D2F",
                     nil))

local msg = "testing friend add(just some dude)"
print("fa:", comm:friend_add("DB116EA92FC6E85C24B9AF5E8F61BAF1F853B2D8B21E9D4AF8E29532435099085C589E40DC1A", msg, #msg, nil))

comm:loop()
