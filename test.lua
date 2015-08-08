local ffi = require "ffi"

local Tox = require "Tox"

local comm = Tox.new({ savedata_file=true })

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

comm:update_callback("self_connection_status",
                     function(_, status) print("status", status) end)

comm:update_friend_callback("connection_status",
                            function(self, friend, status) print("friendstatus", status) end)

comm:update_friend_callback(
   "message",
   function(self, friend, kind, msg, msg_len)
      print(self,friend, kind,msg,msg_len)
      print("msg", ffi.string(msg, msg_len)) -- friend:pubkey())
      friend:send_message("Super message replying time!")
end)

print(hexify(comm:self_get_address(), 38))

print(comm:bootstrap("54.199.139.199",
                     33445, "951C88B7E75C867418ACDB5D273821372BB5BD652740BCDF623A4FA293E75D2F",
                     nil))

local msg = "testing friend add(just some dude)"
print("fa:", comm:friend_add("DB116EA92FC6E85C24B9AF5E8F61BAF1F853B2D8B21E9D4AF8E29532435099085C589E40DC1A", msg, #msg, nil))

print("SAVEDATA:", comm:get_savedata())

print(comm:write_savedata())

local socket = require "socket"
while true do
   comm:iterate()
   socket.sleep(comm:iteration_interval()/1000.0)
end
