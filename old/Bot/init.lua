--  Copyright (C) 06-09-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local ffi = require "ffi"
local raw = require "tox_comms.ffi.raw"
local Tox = require "tox_comms.Tox"

local Bot = {}
for k,v in pairs(Tox) do Bot[k] = v end
Bot.Friend = require "tox_comms.Bot.Friend"
Bot.__index = Bot

Bot.savedata_file = true
Bot.auto_bootstrap = true

local function proper_io_lines(file)
   local fd = io.open(file)
   if fd then
      fd:close()
      return io.lines(file)
   else
      return ipairs{} -- F*ck it.
   end
end

Bot.name = "default"

function Bot:init()
   self.dir = self.dir or os.getenv("HOME") .. "/.mybot/" .. self.name .. "/"
   os.execute("mkdir -p " .. self.dir)

   if not self.friends then
      self.friends = {}
      for addr in proper_io_lines(self.dir .. "add_friendr.txt") do
         self:add_friend_norequest(addr)
      end
   end

   Tox.init(self)

   for _, name in ipairs{"name", "status_message", "status", "connection_status",
                         "typing", "read_receipt", "message"} do
      self:update_friend_callback(name)
   end

   self:update_callback("friend_request", function(cdata, addr)
      self:add_friend_norequest(addr)
   end)
end

function Bot:save()
   -- Savedata.
   self:write_savedata(self.dir .. "/savedata")
   -- Friend list.
   local fd = io.open(self.dir .. "friend_addr.txt", "w")
   for addr, fr in pairs(self.friends) do
      fd:write(addr .. "\n")
      fr:save()
   end
   fd:close()
end

return Bot
