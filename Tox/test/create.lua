
local Tox = require "Tox"
local n = Tox:new()

--for k,v in pairs(getmetatable(n)) do print(k,v) end

print(n:status())
print(n:set_name("miauw"))
print(n:get_name())
