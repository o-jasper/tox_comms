-- Absolute single track mind. Dont be this guy!

local ffi = require "ffi"

local Tox = require "tox_comms.Tox"

local dt = tonumber(arg[2]) or 0.05
local len = tonumber(arg[3]) or 1000

local comm = Tox.new({ name="punchies", pubkey_name="punchies",
                       savedata_file=true, auto_bootstrap=true})

local add_msg = "Hi i am punchies :D"
print("friend_add", arg[1], comm:friend_add(arg[1], add_msg, #add_msg, nil))

comm:update_callback("self_connection_status",
                     function(_, status) print("status", status) end)


local PunchyFriend = require "tox_comms.bin.lib.PunchyFriend"
local pf = {}

local function ensure_pf(friend)
   local got = pf[friend:pubkey()]
   if not got then
      got = PunchyFriend.new{f=friend, tox=comm, dt=dt, len=len}
      pf[friend:pubkey()] = got
      friend:send_message("Punchies? :D")
   end
   return got
end

comm:update_friend_callback("connection_status",
                            function(self, friend, status)
                               ensure_pf(friend)
                               print("friendstatus", friend:pubkey(), status)
end)

comm:update_friend_callback(
   "message",
   function(self, friend, kind, msg, msg_len)
      print(self,friend, kind,msg,msg_len)
      local str = ffi.string(msg, msg_len)
      local got = ensure_pf(friend)
      print("msg", got, string.sub(friend:pubkey(), 10), str)
      got:recv_msg(str)
end)

print("write_savedata", comm:write_savedata())
print("self_get_name",  comm:self_get_name())

local socket = require "socket"

while true do
   comm:iterate()
   socket.sleep(comm:iteration_interval()/1000.0)
   for _, p in pairs(pf) do p:maybe_punch() end
end
