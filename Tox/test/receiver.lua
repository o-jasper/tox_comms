local flags = {}
for key in string.gmatch(arg[1] or "", ",?([^,]+),?") do flags[key] = true end

-- Prints what it receives.

local Tox = require "Tox"
local n = Tox:new{ auto_bootstrap=true }
local to_c = require "Tox.ffi.to_c"

--for k,v in pairs(getmetatable(n)) do print(k,v) end
n:set_name("Test receiving")
n:set_status_message("shits being lua here")
print(n:name(), n:addr())
print(n:status_message())
print("---Setting callbacks")

for _,k in ipairs{"name", "status_message", "status", "connection_status",
                  "message"} do
   if k then
      local key = k
      n:set_friend_callback(key, function(...) print(key, ...) end)
   end
end

if flags.accept then
   n:set_friend_callback("request",function(tox, addr, ...)
                        local haddr = to_c.enhex(addr, 32)
                        print(key, haddr, ...) -- to_c.str(msg))
                        n:ensure_fid(haddr)
   end)
else
   n:set_friend_callback("request", print)
end

local the_friend

local function do_fr()
   the_friend = arg[2] or "E4D192A2A0095F11F1B0CE568AD1C0CD2B2F6C349E59231B25FD456D89E5605AB0C95743686D"
   print("--Friend request to", the_friend)
   n:friend_request(the_friend, "i am a test")

   n:send_message(the_friend, "Da message")
end
if flags.fr then do_fr() end

if flags.noloop then return end

print("---Entering loop")
local sleep = require("socket").sleep
local k = 0
while true do
   n:step()
   sleep(n:step_interval()/1000.0)
   k = k + 1
   if k%100 == 0 then
      print("*", k, n:connection_status())
      if the_friend and flags.whine then
         n:send_message(the_friend, string.format("K %d", k))
      end
      if flags.fr2 then
         flags.fr2 = false
         do_fr()
      end
   end
end
