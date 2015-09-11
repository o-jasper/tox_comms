--  Copyright (C) 06-09-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

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
   if addr then
      local got = self.friends[addr]
      if not got then
         local args = {}
         for k,v in pairs(self.Friend_args) do args[k] = v end
         -- Fetch previous state.
         local from_file = self.dir .. "/friends/" .. addr .. "/self.state"
         if self.use_file_encode ~= false then
            local tab = (self.use_file_decode or require("storebin").file_decode)(from_file)
            for k,v in pairs(tab or {}) do
               args[k] = v
            end
         end

         args.friend = friend  -- Actually dont want this to be in there.
         args.bot = self
         args.addr = addr
         got = self.Friend:new(args)
         self.friends[addr] = got
      end
      self.friend_not_done_fids[friend.fid] = nil
      return got
   else
      self.friend_not_done_fids[friend.fid] = true
      return false
   end
end

function Bot:friend_add(addr, add_msg)
   return self:ensure_friend(self.tox:friend_add(addr, add_msg, #add_msg, nil))
end
function Bot:friend_add_norequest(addr)
   return self:ensure_friend(self.tox:friend_add_norequest(addr))
end

Bot.savedata_file = true
Bot.auto_bootstrap = true

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

   self.friend_not_done_fids = {}
   if not self.friends then
      self.friends = {}
      for addr in proper_io_lines(self.dir .. "friend_addr.txt") do
         self:friend_add_norequest(addr)
      end
   end

   if self.status_message then
      tox:set_status_message(self.status_message)
   end
   if self.use_name or self.name then
      tox:self_set_name(self.use_name or self.name)
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
   -- Savedata.
   self.tox:write_savedata()
   -- Friend list.
   local fd = io.open(self.dir .. "friend_addr.txt", "w")
   for addr, fr in pairs(self.friends) do
      fd:write(addr .. "\n")
      fr:save()
   end
   fd:close()
end

function Bot:iterate()
   self.tox:iterate()
   for fid, v in pairs(self.friend_not_done_fids) do
      if v == true then
         if self:ensure_friend(self.tox.friends[fid]) then
            self.friend_not_done_fids[fid] = nil
         end
      elseif v ~= nil then  --dont expect nil either, but..
         error("Didnt expect non-true?")
      end
   end
end

return Bot
