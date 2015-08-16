--  Copyright (C) 14-08-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local ffi  = require "ffi"

local ToxFriend = require "tox_comms.ToxFriend"

local ToxChannelMsg = {}
for k,v in pairs(ToxFriend) do ToxChannelMsg[k] = ToxFriend[k] end

ToxChannelMsg.__name = "ToxChannelMsg"
ToxChannelMsg.__index = ToxChannelMsg

function ToxChannelMsg.new(self)
   self.data_nr = 0
   self.cdata = self.tox.cdata
   self.funs = {}
   self.return_cb = {}
   self.returning_funs = {}
   return setmetatable(self, ToxChannelMsg)
end

-- Upgrades a ToxFriend to a channel.
function ToxChannelMsg.from_Friend(self)
   if getmetatable(self) == ToxChannelMsg then
      return self
   else
      -- Add all the info needed.
      self.cdata = self.tox.cdata
      self.data_nr = 0
      self.funs = {}
      return ToxChannelMsg.new(self)
   end
end

-- Just in case one might want to change them.
local json = require "json"

ToxChannelMsg.max_len = 1372

function ToxChannelMsg:channel_data(data, way, cb_data)
   local nr = self.data_nr + 1
   self.data_nr = nr
   local header = string.format("~~%x:%s:", nr, way)
   if #header + #data > self.max_len then  -- Cant send at once.
--      local n, j = 0, 0
--      while j < #data do
--         local chunk = string.format("~~%x:%x", nr,n)
--         local sendlen = self.max_len - #chunk
--         self:send_message(chunk .. string.sub(data, j, j + sendlen))
--         j = j + sendlen
--         n = n + 1
--      end
      -- TODO send the number of chunks in the entire thing.
      return false  -- TODO not yet implemented
   else  -- Just send it.
      self:send_message(header .. data)
   end
   return nr
end

function ToxChannelMsg:cb_message(tp, msg)
   local msg = ffi.string(msg)
   if tp == 0 then
      if string.find(msg, "^~~[%x]+:[%x]+:") then
         --      local j1 = string.find(msg, ":", 1, true)
         --      local j2 = string.find(msg, ":", j1 + 1, true)
         --      
         --      local nr = tonumber(string.sub(msg, 2, j1-1), 16)  -- Index of the message.
         --      local n  = tonumber(string.sub(msg, j1+1, j2-1), 16) -- Index of the chunk.
         --      
         --      local chunks = self.chunks[nr] or {}
         --      self.chunks[nr] = chunks
         --      chunks[n] = string.sub(msg, j2+1)
         return false
      else
         local _, j1 = string.find(msg, "^~~[%x]+:")
         local j2, j3 = string.find(msg, ":", j1+1, true)
         
         local kind = string.sub(msg, j1+1,j2-1)  -- Kind of message.
         local fun = self.data_cb[kind]
         if fun then
            local nr = tonumber(string.sub(msg, 3, j1-1), 16)  -- Index of the message.
            fun(self, nr, string.sub(msg, j3+1))
         end
      end
   end
end

local data_cb = {}
ToxChannelMsg.data_cb = data_cb

-- On-receive-call.
function data_cb:json_call(nr, data)
   local call = json.decode(data)
   local fun = self.funs[call.name]
   if fun then  -- Got something for this.
      if self.returning_funs[name] then  -- Return the resulting value.
         self:channel_data(json.encode(fun(unpack(call.args))), "json_ret")
      else  -- Just call the function.
         fun(unpack(call.args))
      end
   end
end

-- On-receive-return-result of a call.
function data_cb:json_ret(nr, data)
   local ret = json.decode(data)
   local ret_cb = self.return_cb[nr]  -- The return callback.
   if ret_cb then
      self.return_cb[nr] = nil  -- No longer needed.
      ret_cb(unpack(ret.args))
   end
end

function ToxChannelMsg:call(name, return_callback)
   return function(...)
      local nr = self:channel_data(json.encode({name=name, args={...}}), "json_call")
      self.return_cb[nr] = return_callback
   end
end

return ToxChannelMsg
