local ffi = require "ffi"

local from_c = require "ffi.from_c"

local Tox = require "Tox"
local ToxChannel = require "ToxChannelMsg"

local a = Tox.new({ pubkey_name = "a", savedata_file=true, auto_bootstrap=true })
local b = Tox.new({ pubkey_name = "b", savedata_file=true, auto_bootstrap=true })

a:write_savedata()
b:write_savedata()

local function hexify(list, n)
   local hex = "0123456789ABCDEF"
   local i, ret = 0, ""
   while i < n do
      assert(list[i], string.format("ran out: %d vs %d", i, n))
      local k, l = math.floor(list[i]/16) + 1, list[i]%16 + 1
      ret = ret .. string.sub(hex, k, k) .. string.sub(hex, l, l)
      i = i + 1
   end
   return ret
end

-- Add, and accept an add.

local function send_print(a_friend, b_friend) -- Print if that function received.
   a_friend.funs.print = print
   b_friend.funs.print = print
   local x = math.random()
   b_friend:call("print")(x, 1,2,3,4)
   print("added it..")
end

b:update_callback("friend_request",
                  function(_, pubkey, message, len)
                     local f = b:friend_add_norequest(pubkey)
                     print("friendadd", ffi.string(message, len), f.fid)
                     b.friends[f.fid] = ToxChannel.from_Friend(f)
                     
                     send_print(a.friends[0], f)
end)

local f = a:friend_add(hexify(b:self_get_address(), 38), "add me plz")
a.friends[f.fid] = ToxChannel.from_Friend(f)
print(f.fid)

a:update_callback("self_connection_status",
                  function(_, status) print("status", "a", status) end)
a:update_friend_callback("connection_status",
                         function(_, friend, status) print("friendstatus", "a-b", status) end)
b:update_callback("self_connection_status",
                  function(_, status) print("status", "b", status) end)
b:update_friend_callback("connection_status",
                         function(_, friend, status) print("friendstatus", "b-a", status) end)

a:update_friend_callback("message")
b:update_friend_callback("message")

print("----")

local socket = require "socket"

local last_t, n = 0,0
while true do
   a:iterate()
   b:iterate()
   if os.time() > last_t + 2 then
      last_t = os.time()
      n = n + 1
      if b.friends[0] then
         print("attempt", n)
         b.friends[0]:call("print")(math.random(), "ska", n)
      else
         print("not added yet", n)
      end
   end
   socket.sleep(math.min(b:iteration_interval()/1000.0,
                         a:iteration_interval()/1000.0))
end
