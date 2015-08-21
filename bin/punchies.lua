-- Absolute single track mind. Dont be this guy!

local ffi = require "ffi"

local Tox = require "Tox"

local socket = require "socket"

local PunchyFriend = {}
PunchyFriend.__index = PunchyFriend

local dt = tonumber(arg[2]) or 0.05
local len = tonumber(arg[3]) or 1000

local add_msg = "Hi i am punchies :D"
PunchyFriend.add_msg = add_msg

function PunchyFriend.new(self)
   assert(self.f, "no friend specified?")
   self = setmetatable(self, PunchyFriend)
   self:init()
   return self
end

function PunchyFriend:init()
   self.punchy_mode = false  -- Just to be explicit.
   self.next_time = socket.gettime()
end

local function findlist(str, list)
   for _, el in ipairs(list) do
      if string.find(str, el) then return true end
   end
   return false
end

function PunchyFriend:recv_msg(msg)
   local friend = self.f
   local str = string.lower(msg)
   if not self.punchy_mode and
      (string.find(str, "punchies") and findlist(str, {"yes", "yay"}))
   then
      friend:send_message("YAY! PUNCHIEES :D :D :D")
      self.punchy_mode = true
   elseif string.find(str, "^.add [%x]+$") then
      if friend:pubkey() == arg[1] then
         local addr = string.sub(str, 5)
         print("cmd friend_add", addr,
               comm:friend_add(addr, self.addmsg, #self.add_msg, nil))
      else
         friend:send_message("No authoritor")
      end
   else
      if self.punchy_mode and findlist(str, {"no", "stop", "au", "hurt"}) then
         friend:send_message("Awww :'(")
         self.punchy_mode = false
      end
   end
end

-- Random string for the punching.
local function rand_str(len)
   local ret = {}
   while len > 0 do
      table.insert(ret, math.random(256) - 1)
      len = len - 1
   end
   return string.char(unpack(ret))
end

function PunchyFriend:maybe_punch(msg)
   local friend = self.f
   local t = socket.gettime()
   if not self.punchy_mode then self.next_time = t end
   while self.next_time < t do
      friend:send_message(rand_str(len))
      self.next_time = self.next_time + dt
   end   
end

local comm = Tox.new({ name="punchies", pubkey_name="punchies",
                       savedata_file=true, auto_bootstrap=true})

print("friend_add", arg[1], comm:friend_add(arg[1], add_msg, #add_msg, nil))

comm:update_callback("self_connection_status",
                     function(_, status) print("status", status) end)

local pf = {}

comm:update_friend_callback("connection_status",
                            function(self, friend, status)
                               local got = pf[friend:pubkey()]
                               if not got and status > 0 then
                                  pf[friend:pubkey()] = PunchyFriend.new{f=friend}
                                  friend:send_message("Punchies? :D")
                               end
                               print("friendstatus", status)
end)

comm:update_friend_callback(
   "message",
   function(self, friend, kind, msg, msg_len)
      print(self,friend, kind,msg,msg_len)
      local str = ffi.string(msg, msg_len)
      local got = pf[friend:pubkey()]
      print("msg", got, string.sub(friend:pubkey(), 10), str)
      if got then
         got:recv_msg(str)
      end
end)

print("write_savedata", comm:write_savedata())
print("self_get_name",  comm:self_get_name())

local next_time = socket.gettime()
while true do
   comm:iterate()
   socket.sleep(comm:iteration_interval()/1000.0)
   for _, p in pairs(pf) do p:maybe_punch() end
end
