-- Absolute single track mind. Dont be this guy!

local socket = require "socket"

local PunchyFriend = {}
PunchyFriend.__index = PunchyFriend

PunchyFriend.add_msg = "Hi i am punchies :D"

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
               self.tox:friend_add(addr, self.addmsg, #self.add_msg, nil))
      else
         print("no authoritor", addr)
         friend:send_message("No authoritor")
      end
   elseif self.punchy_mode and findlist(str, {"no", "stop", "au", "hurt"}) then
      friend:send_message(":( Awww :'(")
      self.punchy_mode = false
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
   if not self.punchy_mode then
      self.next_time = t
      return
   end
   while self.next_time < t do
      friend:send_message(rand_str(self.len))
      self.next_time = self.next_time + self.dt
   end   
end

return PunchyFriend
