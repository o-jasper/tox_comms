local tox = require "init"

print(tox.version_major(), tox.version_minor(), tox.version_minor)

--local opts = tox.options_new()

--print(tox.new(opts, nil))

local raw = require "raw"

local n = tox.new(nil,nil,0,nil)

--for k,v in pairs(getmetatable(n)) do print(k,v) end

print(n:self_get_status())
print(n:self_set_name("miauw"))
print(n:self_get_name())
