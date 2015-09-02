local Bot = require "tox_comms.Bot"

local bot = Bot:new()

local socket = require "socket"

local add_msg = "bot 10k"
print("friend_add", arg[1], bot.tox:friend_add(arg[1], add_msg, #add_msg, nil))

bot:save()

while true do
   bot.tox:iterate()
   socket.sleep(bot.tox:iteration_interval()/1000.0)
end
