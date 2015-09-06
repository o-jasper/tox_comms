local ffi = require "ffi"
local Tox = require "tox_comms.Tox"

local Bot = {}
Bot.__index = Bot

Bot.Friend = require "tox_comms.Bot.Friend"
Bot.Friend_args = {}

function Bot:new(new)
   new = setmetatable(new or {}, self)
   self:init()
   return new
end

function Bot:ensure_friend(friend)
   local addr = friend:addr()
   local got = self.friends[addr]
   print("ensuring friend", addr, got)
   if not got then
      local args = {}
      for k,v in pairs(self.Friend_args) do args[k] = v end
      args.friend = friend
      args.bot = self
      got = self.Friend:new(args)
      self.friends[addr] = got
   end
   return got
end

function Bot:friend_add(addr, add_msg)
   print(addr)
   return self:ensure_friend(self.tox:friend_add(addr, add_msg, #add_msg, nil))
end
function Bot:friend_add_norequest(addr)
   print(addr)
   return self:ensure_friend(self.tox:friend_add_norequest(addr))
end

Bot.savedata_file = true
Bot.auto_bootstrap = true

local serial = require "tox_comms.storebin.file"

local function proper_io_lines(file)
   local fd = io.open(file)
   if fd then
      fd:close()
      return io.lines(file)
   else
      return ipairs({}) -- F*ck it.
   end
end

Bot.name = "default"

function Bot:init_tox()
   self.tox = Tox.new {
      dirname = self.dir .. "/tox/",
      name = "bot_" .. self.name, pubkey_name="bot_" .. self.name,
      savedata_file=self.savedata_file, auto_bootstrap=self.auto_bootstrap
   }
   return self.tox
end

function Bot:init()
   self.dir = self.dir or os.getenv("HOME") .. "/.mybot/" .. self.name .. "/"
   os.execute("mkdir -p " .. self.dir)

   local tox = self:init_tox()

   if not self.friends then
      self.friends = {}
      for addr in proper_io_lines(self.dir .. "friend_addr.txt") do
         self:friend_add_norequest(addr)
      end
   end
   
   if self.status_message then
      tox:set_status_message(self.status_message)
   end

   local function id(...) return ... end
   local function friend_responder(name, handle)
      local handle = handle or id
      return function(_, friend, ...)
         local got = self:ensure_friend(friend)
         if got ~= false then  -- Setting false blacklists; ignores.
            got["on_" .. name](got, handle(...))
         end
      end
   end
   local function friend_respond_to(name, handle)
      tox:update_friend_callback(name, friend_responder(name, handle))
   end
   friend_respond_to("connection_status")
   
   friend_respond_to("message", function(kind, msg, msg_len)
                        return kind, ffi.string(msg, msg_len)
   end)
   friend_respond_to("status_message", function(msg, msg_len)
                        return ffi.string(msg, msg_len)
   end)
   friend_respond_to("name", function(name, name_len)
                        return ffi.string(name, name_len)
   end)
end

function Bot:save()
   self.tox:write_savedata()
   local fd = io.open(self.dir .. "friend_addr.txt", "w")
   for addr, fr in pairs(self.friends) do
      fd:write(addr .. "\n")
      fr:save()
   end
   fd:close()
end

return Bot
