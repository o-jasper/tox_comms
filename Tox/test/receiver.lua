local flags = {}
for key in string.gmatch(arg[1] or "", ",?([^,]+),?") do flags[key] = true end

-- Prints what it receives.

local Tox = require(flags.direct and "Tox.Bare" or "Tox.Evented")
local n = Tox:new{ auto_bootstrap=true }
local to_c = require "Tox.ffi.to_c"

--for k,v in pairs(getmetatable(n)) do print(k,v) end
n:set_name("Test receiving")
n:set_status_message("shits being lua here; i am a lua development test, if you're not the dev, this is an accident.")
print(n:name(), n:addr())
print(n:status_message())
print("---Setting callbacks")


--local ffi = require "ffi"
--lua_State *luaL_newstate (void);
--int luaL_loadstring (lua_State *L, const char *s);
--int lua_pcall (lua_State *L, int nargs, int nresults, int msgh);
--int lua_getglobal (lua_State *L, const char *name); -- Hrmm doesn't really get it out..

local _, copas = pcall(function() return require "copas" end)

copas = flags.copas and copas

for _,key in pairs{"name", "status_message", "status", "connection_status", "message"} do
   n:set_friend_callback(key, print)
end

local the_friend

local function do_fr()
   --   the_friend = arg[2] or "E4D192A2A0095F11F1B0CE568AD1C0CD2B2F6C349E59231B25FD456D89E5605AB0C95743686D"
   the_friend = "AF543D284AF81D2A6C6E41E57531CBD4F64EA963BBA299CE3016160A74BE66073B2D8E69AA60"
   print("--Friend request to", the_friend)
   n:friend_request(the_friend, "i am a development test, if you're not the dev, this is an accident.")

   n:send_message(the_friend, "Da message")
end
if flags.fr then do_fr() end

if flags.noloop then return end

if copas then
   print("---Entering loop", "COPAS")
   local k = 0
   print(copas.addthread(function()
         while true do
            k = k + 1
            n:step()
            copas.sleep(n:step_interval()/1000.0)
         end
   end))
   copas.addthread(function()
         while true do
            print("*", k, n:connection_status())
            copas.sleep(5)
         end
   end)
   copas.loop()
else
   print("---Entering loop", "non-copas")
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
end
