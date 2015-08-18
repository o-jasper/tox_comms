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
   self.transfers = {}
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

ToxChannelMsg.chunk_max_len = 1372
ToxChannelMsg.send_chunk = ToxChannelMsg.send_message

function ToxChannelMsg:channel_data(name, data)
   local nr = self.data_nr + 1
   self.data_nr = nr
   local header = string.format("~~%x:%s:", nr, name)
   if #header + #data > self.chunk_max_len then  -- Cant send at once.
      data = name .. ":" .. data  -- Still prepend name
      local n, j = 0, 0
      while j < #data do
         local chunk = string.format("~~%x:%x:", nr,n)
         local sendlen = self.chunk_max_len - #chunk
         self:send_chunk(chunk .. string.sub(data, j, j + sendlen - 1))
         j = j + sendlen
         n = n + 1
      end
      -- The number, so we can get them all.
      self:send_chunk(string.format("~~%x:N=%x", nr, n))
   else  -- Just send it.
      self:send_chunk(header .. data)
   end
   return nr
end

function ToxChannelMsg:check_got_chunks(nr, chunks)
   if chunks.n and chunks.n == chunks.got_cnt then
      -- Have it all, put it together, can call it.
      local data = chunks[0] .. table.concat(chunks)
      local j = string.find(data, ":", 1, true)
      local name = string.sub(data, 0, j-1)
      local fun = self.data_cb[name]
      if fun then  -- If has function, get it.
         fun(self, nr, string.sub(data, j+1))
      end
      -- clean up.
      self.transfers[nr] = nil
   end
end

-- TODO annoying they're mostly getting at the same data..
function ToxChannelMsg:cb_chunk(data)
   if string.find(data, "^~~[%x]+:N=[%x]+$") then  -- Length indicator
      local j1 = string.find(data, ":", 1, true)

      local nr = tonumber(string.sub(data, 3, j1-1), 16)
      local chunks = self.transfers[nr] or {}
      self.transfers[nr] = chunks

      chunks.n = tonumber(string.sub(data, j1+3), 16)
      self:check_got_chunks(nr, chunks)
   elseif string.find(data, "^~~[%x]+:[%x]+:") then
      local j1 = string.find(data, ":", 1, true)
      local j2 = string.find(data, ":", j1 + 1, true)

      local nr = tonumber(string.sub(data, 3, j1-1), 16)  -- Index of the message.
      local n  = tonumber(string.sub(data, j1+1, j2-1), 16) -- Index of the chunk.

      local chunks = self.transfers[nr] or {}
      self.transfers[nr] = chunks
      chunks.got_cnt = (chunks.got_cnt or 0) + 1
      chunks[n] = string.sub(data, j2+1)

      self:check_got_chunks(nr, chunks)
   else
      local _, j1 = string.find(data, "^~~[%x]+:")
      local j2, j3 = string.find(data, ":", j1+1, true)

      local name = string.sub(data, j1+1,j2-1)  -- Kind of message.
      local fun = self.data_cb[name]
      if fun then
         local nr = tonumber(string.sub(data, 3, j1-1), 16)  -- Index of the message.
         fun(self, nr, string.sub(data, j3+1))
      end
   end
end

function ToxChannelMsg:cb_message(tp, msg)
   if tp == 0 then
      self:cb_chunk(ffi.string(msg))
   end
end

local data_cb = {}
ToxChannelMsg.data_cb = data_cb

-- On-receive-call.
function data_cb:json_call(nr, data)
   local j = string.find(data, ":", 1, true)
   local name = string.sub(data, 1, j-1)
   local args = json.decode(string.sub(data, j+1))
   local fun = self.funs[name]
   if fun then  -- Got something for this.
      if self.returning_funs[name] then  -- Return the resulting value.
         self:channel_data("json_ret", json.encode(fun(unpack(args))))
      else  -- Just call the function.
         fun(unpack(args))
      end
   end
end

-- On-receive-return-result of a call.
function data_cb:json_ret(nr, data)
   local ret = json.decode(data)
   local ret_cb = self.return_cb[nr]  -- The return callback.
   if ret_cb then
      self.return_cb[nr] = nil  -- No longer needed.
      ret_cb(unpack(ret))
   end
end

-- Uses the two above to make calls.
function ToxChannelMsg:call(name, return_callback)
   return function(...)
      local nr = self:channel_data("json_call", name .. ":" .. json.encode({...}))
      self.return_cb[nr] = return_callback
   end
end

return ToxChannelMsg
