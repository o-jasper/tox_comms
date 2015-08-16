--  Copyright (C) 14-08-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local ffi  = require "ffi"

local ToxFriend = require "tox_comms.ToxFriend"

local ToxChannel = {}
for k,v in pairs(ToxFriend) do ToxChannel[k] = ToxFriend[k] end

ToxChannel.__name = "ToxChannel"
ToxChannel.__index = ToxChannel

function ToxChannel.new(self)
   self.call_nr = 0
   self.cdata = self.tox.cdata
   self.current = {}
   self.return_cb = {}
   self.funs = {}
   return setmetatable(self, ToxChannel)
end

-- Upgrades a ToxFriend to a channel.
function ToxChannel.from_Friend(self)
   if getmetatable(self) == ToxChannel then
      return self
   else
      -- Add all the info needed.
      self.call_nr = 0
      self.cdata = self.tox.cdata
      self.current = {}
      self.return_cb = {}
      self.funs = {}
      return ToxChannel.new(self)
   end
end

-- Just in case one might want to change them.
local json = require "json"
ToxChannel.encode = json.encode
ToxChannel.decode = json.decode

ToxChannel.call_file_kind = 1023

function ToxChannel:call(name, return_callback)
   self.call_nr = self.call_nr + 1
   -- Register the function that has to respond on-return.
   self.return_cb[self.call_nr] = return_callback

   return function(...)
      local json = self.encode{...}
      assert(type(self.call_file_kind) == "number")
      local nr = self:file_send(self.call_file_kind, #json,
                                string.format("fn:%s:%x", name, self.call_nr))
      self:file_whole_data(nr, json)
   end
end

-- Send return values.
function ToxChannel:ret(name, data, call_nr)
   local json = self.encode(data)
   local nr = self:file_send(self.call_file_kind, #json,
                             string.format("ret:%s:%x", name, call_nr))
   self:file_whole_data(nr, json)
end

local function name_and_number(filename)
   local _, i1 = string.find(filename, ":", 1, true)
   local _, i2 = string.find(filename, ":", i1 + 1, true)
   return string.sub(filename, i1 + 1, i2 - 1), tonumber(string.sub(filename, i2 + 1), 16)
end

function ToxChannel:cb_file_recv(file_nr, kind, file_size, filename, filename_length)
   local filename = ffi.string(filename, filename_length)
   local is_ret = string.find(filename, "^ret:.+:[%x]+$")
   if string.find(filename, "^fn:.+:[%x]+$") or is_ret then
      local name, call_nr = name_and_number(filename)
      self.current[file_nr] = { call_nr = call_nr, name=name, is_ret = is_ret,
                                json="", len = filename_size }
   end
end

function ToxChannel:cb_file_recv_chunk(file_nr, pos, data, len)
   local cur = self.current[file_nr]
   if cur then
      if #cur.json == cur.len then -- should be finished.
         assert(cur.len == #cur.json)
         local ret_cb = self.return_cb[cur.call_nr]
         if ret_cb then  -- It is a return value.
            assert(cur.is_ret)
            ret_cb(self, unpack(self.decode(cur.json)))
            return
         end
         local fun = self.funs[cur.name]  -- If there is a function for this, use it.
         if fun then
            local result = fun(self, unpack(self.decode(cur.json)))
            if self.has_return[cur.name] then  -- If return result for this.
               self:ret(cur.name, result)
            end
            return
         end
         return  -- Else... well other side is asking for features we do not have.
      else
         local data = ffi.string(data, len)
         cur.json = cur.json .. data -- TODO/NOTE assumes that it is in order.
      end
   end
end

--typedef void tox_file_chunk_request_cb(Tox *tox, uint32_t friend_number, uint32_t file_number, uint64_t position, size_t length, void *user_data)
--typedef void tox_file_recv_chunk_cb(Tox *tox, uint32_t friend_number, uint32_t file_number, uint64_t position, const uint8_t *data, size_t length, void *user_data)
--typedef void tox_file_recv_control_cb(Tox *tox, uint32_t friend_number, uint32_t file_number, TOX_FILE_CONTROL control, void *user_data)

return ToxChannel
