local Bot = require "tox_comms.Bot"

local bot = Bot:new()
print("Myself:", bot:addr())

local socket = require "socket"

local stop = false
if arg[1] then
   bot:friend_add(arg[1], "bot 10k")
end

bot:save()
print("First iteration")
bot:iterate()

print("Going into loop")
local stopcnt = 100
local last_t = os.time()
while stopcnt > 0 do
   socket.sleep(bot:iteration_interval()/1000.0)
   bot:iterate()
   if stop then
      if stopcnt == 100 then print("stopping...") end
      stopcnt = stopcnt - 1
   end
end

print("Asked to quit, saving")
bot:save()

