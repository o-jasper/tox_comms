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
   local pubkey = friend:pubkey()
   local got = self.friends[pubkey]
   if not got then
      local args = {}
      for k,v in pairs(self.Friend_args) do args[k] = v end
      args.friend = friend
      args.bot = self
      got = self.Friend:new(args)
      self.friends[pubkey] = got
   end
   return got
end

Bot.savedata_file = true
Bot.auto_bootstrap = true

local fjson = require "tox_comms.util.fjson"

function Bot:load_friends()
   self.friends = fjson.decode(self.dir .. "friends.json") or {}
   for i, el in ipairs(self.friends) do
      self.friends[i] = self.Friend:new_from_table(self.el)
   end
end

Bot.name = "default"
function Bot:init()
   self.dir = self.dir or os.getenv("HOME") .. "/.mybot/" .. self.name .. "/"
   os.execute("mkdir -p " .. self.dir)

   if not self.friends then
      self:load_friends()
   end

   local tox = Tox.new{ 
      dirname = self.dir .. "/tox/",
      name = "bot_" .. self.name, pubkey_name="bot_" .. self.name,
      savedata_file=self.savedata_file, auto_bootstrap=self.auto_bootstrap
   }
   self.tox = tox
   
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
   fjson.encode(self.dir .. "friends.json", self.friends)
end

return Bot
