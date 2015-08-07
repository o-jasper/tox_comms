--  Copyright (C) 07-08-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local ffi = require "ffi"
local to_c = require "tox_comms.ffi.to_c"

local ToxFriend = require "tox_comms.ToxFriend"

local raw = require "tox_comms.ffi.raw"

local tox_funlist = {
   bootstrap = false,
   self_get_name_size = false,
   self_get_name = true,
   self_set_name = true,
   self_get_connection_status = false,
   self_set_status_message = true,
   self_get_status_message_size = false,
   self_get_status_message = true,
   self_set_status = false,
   self_get_status = false,
   self_get_public_key = true,
   self_get_address = true,
   self_get_secret_key = true,

   get_savedata = true,

   friend_add = true,
   friend_add_norequest = true,
   friend_by_public_key = true,
   self_get_friend_list_size = false,
   self_get_friend_list = true,
   self_set_typing = false,
   add_tcp_relay = false,
   file_control = false,
   file_seek = false,
   file_get_file_id = false,
   file_send = false,
   file_send_chunk = false,
   self_get_udp_port = false,
   self_get_tcp_port = false,

   callback_self_connection_status = false,
   callback_friend_name = false,
   callback_friend_status_message = false,
   callback_friend_status = false,
   callback_friend_connection_status = false,
   callback_friend_typing = false,
   callback_friend_read_receipt = false,
   callback_friend_request = false,
   callback_friend_message = false,
   callback_file_recv_control = false,
   callback_file_chunk_request = false,
   callback_file_recv = false,
   callback_file_recv_chunk = false,
   callback_friend_lossy_packet = false,
   callback_friend_lossless_packet = false,

   iterate = false,
   iteration_interval = false,
}

local Tox = { 
   __name = "FFI_Tox",
   TOX_PUBLIC_KEY_SIZE = 32,
   TOX_SECRET_KEY_SIZE = 32,
   TOX_ADDRESS_SIZE = 38,
   TOX_MAX_NAME_LENGTH = 128,
   TOX_MAX_STATUS_MESSAGE_LENGTH = 1007,
   TOX_MAX_FRIEND_REQUEST_LENGTH = 1016,
   TOX_MAX_MESSAGE_LENGTH = 1372,
   TOX_MAX_CUSTOM_PACKET_SIZE = 1373,
   TOX_HASH_LENGTH = 32,
   TOX_FILE_ID_LENGTH = 32,
   TOX_MAX_FILENAME_LENGTH = 255,
}

-- Copy-in either raw or 
for k, is_raw in pairs(tox_funlist) do
   local fun = raw["tox_" .. k]
   Tox[is_raw and "_" .. k or k] = function(self, ...) return fun(self.cdata, ...) end
end

function Tox._add_friend_fid(self, fid)
   local friend = ToxFriend.new{fid=fid, tox=self}
   self.friend_list[fid] = friend
   return friend
end

function Tox.friend_add(self, addr, comment)
   local addr, _comment = to_c.addr(addr), to_c.str(comment)
   local fid = raw.tox_friend_add(self.cdata, addr, _comment, #comment, nil)
   return self:_add_friend_fid(fid)
end

function Tox.friend_add_norequest(self, addr, comment)
   local addr, _comment = to_c.addr(addr), to_c.str(comment)
   local fid = raw.tox_friend_add_norequest(self.cdata, addr, _comment, #comment, nil)
   return self:_add_friend_fid(fid)
end

function Tox.friend_by_pubkey(pubkey)
   local fid = tox_friend_by_public_key(self.cdata, to_c.addr(pubkey))
   local got = self.friend_list[fid]
   if not got then
      got = ToxFriend.new{fid=fid, tox=self}
      self.friend_list[fid] = got
   end
   return got
end

-- Functions that use a pointer now just return.

local function Tox_ret_via_arg(name, ...) Tox[name] = to_c.ret_via_arg(name, ...) end
Tox_ret_via_arg("self_get_name")
Tox_ret_via_arg("self_get_status_message")
Tox_ret_via_arg("self_get_friend_list", "uint32_t[?]", true)

function Tox.self_get_friend_list()
   for _,fid in pairs(self:_self_get_friend_list()) do
      if not self.friend_list[fid] then
         self.friend_list[fid] = ToxFriend.new{fid=fid, tox=self}  -- By fid!
      end
   end
   return self.friend_list
end

Tox_ret_via_arg("get_savedata", "uint8_t[?]")

local function Tox_ret_via_arg_no_size(name, ...)
   Tox[name] = to_c.ret_via_args_no_size(name, ...)
end
Tox_ret_via_arg_no_size("self_get_public_key")
Tox_ret_via_arg_no_size("self_get_secret_key")
Tox_ret_via_arg_no_size("self_get_address", "uint8_t[38]")

Tox.__index  = Tox

function Tox_set_default_size(name, ...)
   local rawname = "_" .. name
   Tox[name] = function(self, to, size, err) 
      return self[rawname](self, to, size or #to, err)
   end
end
Tox_set_default_size("self_set_name")
Tox_set_default_size("self_status_message")

Tox.callbacks = {
   self_connection_status = function(_, status)
      print(status)  -- Probably 0 none, 1 tcp, 2 udp
   end,
   friend_connection_status = function(_, status)
      print(status)  -- Probably 0 none, 1 tcp, 2 udp
   end,
   friend_message = function(_, fid, tp, msg, msg_len)
      --assert( #msg == msg_len )
      -- tp is either normal or action.
      --tox_history:add_msg({from_id = ids[fid], tp = tp, msg = msg })
      print(fid, tp, ffi.string(msg, msg_len), msg_len)
   end,

   friend_request = function(_, from_pubkey, msg, msg_len)
      print(ffi.string(from_pubkey, 38), ffi.string(msg, msg_len))
   end,
}

function Tox:update_callbacks()
   for name,cb in pairs(getmetatable(self).callbacks) do
      local cb = self.callbacks[name] or cb
      self["callback_" .. name](self, cb, nil)
   end
end

function Tox.new(self)
   if type(self.opts) == "table" then 
      assert(self.opts.cdata) 
      self.opts = self.opts.cdata
   end
   self.cdata = raw.tox_new(opts, data, len or 0, err)
   self.friend_list = {}
   local ret = setmetatable(self, Tox)
   self:self_set_name(self.name or "(unnamed)")
   ret:update_callbacks()
   return ret
end

function Tox:loop()
   local socket = require "socket"
   while true do
      self:iterate()
      socket.sleep(self:iteration_interval()/1000.0)
   end
end

return Tox
