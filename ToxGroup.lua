
--  Copyright (C) 22-09-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

-- TODO need to actually add the functions in raw..
local raw = require "tox_comms.ffi.raw"
local ffi = require "ffi"
local to_c = require "tox_comms.ffi.to_c"

local ToxGroup = { __name = "ToxGroup" }
ToxGroup.__index = ToxGroup

function ToxGroup:new(new)
   assert(new.tox)
   local new = setmetatable(new, self)
   new.cdata = new.tox.cdata
   new:update_friends()
   return new
end

function ToxGroup:peernumber_is_ours(i)
   return raw.tox_group_peernumber_is_ours(self.cdata, self.gid, i) == 1
end

function ToxGroup:peer_cnt()
   return raw.tox_group_number_peers(self.cdata, self.gid)
end

function ToxGroup:peer_pubkey(i)
   local c_addr = ffi.new("uint8_t[32]")
   local s = raw.tox_group_peer_pubkey(self.cdata, self.gid, i, c_addr)
   return ffi.string(c_addr, 32)
end

function ToxGroup:peername(i)
   local c_name = ffi.new("uint8_t[128]")  -- TOX_MAX_NAME_LENGTH
   local s = raw.tox_group_peername(self.cdata, self.gid, i, c_name)
   return ffi.string(c_name, 128)
end

function ToxGroup:peerfriend(i, mark)
   local c_addr = ffi.new("uint8_t[32]")
   local fid = raw.tox_add_friend_norequest(self.cdata, c_addr, nil)
   local friend = self.tox:add_friend_norequest(ffi.string(c_addr, 32))
   if mark or mark == nil then
      friend.ingroups[self.gid] = {self, i}
   end
   return friend
end

function ToxGroup:update_friends()
   local ret = {}
   for i = 0, self:peer_cnt() - 1 do
      if not self:peernumber_is_ours(i) then
         table.insert(ret, self:peerfriend(i, mark))
      end
   end
   self.friends = ret
   return ret
end

function ToxGroup:invite_friend(fid)
   local fid = (type(fid) == "number" and fid) or fid.fid
   return raw.tox_invite_friend(self.cdata, fid, self.gid)
end

function ToxGroup:send_message(message, kind)
   local c_msg, c_msg_sz = to_c.str(msg), #msg
   if kind == 1 then
      return raw.tox_group_action_send(self.cdata, self.gid, c_msg, c_msg_sz)
   else
      return raw.tox_group_message_send(self.cdata, self.gid, c_msg, c_msg_sz)
   end
end

function ToxGroup:set_title(title)
   local c_title, c_title_sz = to_c.str(title), #title
   return raw.tox_group_set_title(self.cdata, self.gid, c_title, c_title_sz)
end

function ToxGroup:get_title()
   local c_title = ffi.new("uint8_t[256]")  -- 2*TOX_MAX_NAME_LENGTH   
   raw.tox_group_get_title(self.cdata, self.gid, c_title, 256)
   return ffi.string(c_title, 256)
end

function ToxGroup:get_type()
   return raw.tox_group_get_type(self.cdata, self.gid)
end

return ToxGroup
