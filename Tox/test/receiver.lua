-- Prints what it receives.

local Tox = require "Tox"
local n = Tox:new()
local to_c = require "Tox.ffi.to_c"

--for k,v in pairs(getmetatable(n)) do print(k,v) end
n:set_name("Test receiving")
n:set_status_message("shits being lua here")
print(n:name(), n:addr())
print(n:status_message())
print("---Setting callbacks")

for _,k in ipairs{"name", "status_message", "status", "connection_status",
                  "message"} do
   local key = k
   n:update_friend_callback(k, function(...) print(key, ...) end)
end

if arg[1] == "FR" then
   print("--Friend request")
   n:friend_request(arg[2] or "E4D192A2A0095F11F1B0CE568AD1C0CD2B2F6C349E59231B25FD456D89E5605AB0C95743686D", "i am a test")
end

n:update_friend_callback("request",function(tox, addr, ...)
                            local haddr = to_c.enhex(addr, 32)
                            print(key, haddr, ...) -- to_c.str(msg))
                            n:ensure_fid(haddr)
end)

if arg[1] == "noloop" then return end

print("---Entering loop")
local sleep = require("socket").sleep
local k = 0
while true do
   n:step()
   sleep(n:step_interval()/1000.0)
   k = k + 1
   if k%100 == 0 then print("*", k) end
end
