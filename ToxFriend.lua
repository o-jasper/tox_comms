--  Copyright (C) 14-08-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local raw = require "tox_comms.ffi.raw"

local ffi = require "ffi"
local to_c = require "tox_comms.ffi.to_c"

local ToxFriend = { __name = "ToxFriend" }
ToxFriend.__index = ToxFriend

function ToxFriend.new(self)
   self.cdata = self.tox.cdata
   return setmetatable(self, ToxFriend)
end

for k,v in pairs({delete=false, exists=false, get_status="status",
                  get_last_online="last_online", get_typing="typing" }) do
   local name = v or k
   local c_name = "tox_friend_" .. k
   ToxFriend[name] = function(self) raw[c_name](self.cdata, self.fid) end
end

function ToxFriend:pubkey()
   local ret = ffi.new("uint8_t[32]")
   raw.tox_friend_get_public_key(self.cdata, self.fid, ret, nil)
   return ffi.string(ret, 32)
end

function ToxFriend:addr()
   -- TODO .. how to get address?
   local ret = ffi.new("uint8_t[32]")
   local got = raw.tox_friend_get_public_key(self.cdata, self.fid, ret, nil)
   if got then
      return to_c.enhex(ret, 32)
   end
end

function ToxFriend:name()
   local sz = raw.tox_friend_get_name_size(self.cdata, self.fid)
   local ret = ffi.new("uint8_t[?]", sz)
   raw.tox_friend_get_name(self.cdata, self.fid, ret, nil)
   return ffi.string(ret, sz)
end

function ToxFriend:send_message(msg, kind)
   return raw.tox_friend_send_message(self.cdata, self.fid, kind or 0,
                                      to_c.str(msg), #msg, nil)
end

function ToxFriend:send_lossy_packet(data)
   return raw.tox_friend_send_lossy_packet(self.cdata, self.fid, to_c.str(data), #data, nil)
end

function ToxFriend:send_lossless_packet(data)
   return raw.tox_friend_send_lossless_packet(self.cdata, self.fid, to_c.str(data), #data, nil)
end

function ToxFriend:file_send(kind, size, filename, file_id)
   -- TODO mysteriously, the third argument does not work.
   return raw.tox_file_send(self.cdata, self.fid,
                            size, file_id or ffi.new("uint8_t*", nil),
                            to_c.str(filename), #filename, nil)
end

function ToxFriend:file_send_chunk(nr, pos, data)
   return raw.tox_file_send_chunk(self.cdata, self.fid, nr, pos, to_c.str(data), #data, nil)
end
function ToxFriend:file_whole_data(nr, data)
   return raw.tox_file_send_chunk(self.cdata, self.fid, nr, 0, to_c.str(data), #data, nil)
end

return ToxFriend
