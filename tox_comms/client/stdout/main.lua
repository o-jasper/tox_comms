local DoTox  = require "tox_comms.do.Tox"
local EdgeChat = require "tox_comms.EdgeChat"

local Edge = require "tox_comms.client.stdout.Edge"

local bot = DoTox:new{ savedata_file=true, edgechat = EdgeChat:new{Edge=Edge} }

print("My addr", bot:addr())

local socket = require "socket"

local stop = false
if arg[1] then
   print("Adding friend", arg[1])
   bot:add_friend(arg[1], "bot 10k")
end

bot:save()

print("First iteration")
bot:iterate()

print("Going into loop")
local stopcnt = 100
local last_t = os.time()
local i = 0
while stopcnt > 0 do
   socket.sleep(bot:iteration_interval()/1000.0)
   bot:iterate()
   if stop then
      if stopcnt == 100 then print("stopping...") end
      stopcnt = stopcnt - 1
   end
   if i %100 == 0 then
      print("*")
--      bot:do_msg("DB116EA92FC6E85C24B9AF5E8F61BAF1F853B2D8B21E9D4AF8E29532435099085C589E40DC1A",
      --nil, 0, "MIAUW")
   end
   i = i + 1
end

print("Asked to quit, saving")
bot:save()

