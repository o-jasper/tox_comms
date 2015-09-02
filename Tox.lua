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

   get_savedata_size = false,
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
   self.friends[fid] = friend
   return friend
end

function Tox.friend_add(self, addr, comment)
   local addr, _comment = to_c.addr(addr), to_c.str(comment)
   local fid = raw.tox_friend_add(self.cdata, addr, _comment, #comment, nil)
   return self:_add_friend_fid(fid)
end

function Tox.friend_add_norequest(self, addr)
   local addr = to_c.addr(addr)
   local fid = raw.tox_friend_add_norequest(self.cdata, addr, nil)
   return self:_add_friend_fid(fid)
end

function Tox.friend_by_pubkey(pubkey)
   local fid = tox_friend_by_public_key(self.cdata, to_c.addr(pubkey))
   return self.friends[fid] or self:_add_friend_fid(fid)
end

-- Functions that use a pointer now just return.

local function Tox_ret_via_arg(name, ...) Tox[name] = to_c.ret_via_arg(name, ...) end
Tox_ret_via_arg("self_get_name")
Tox_ret_via_arg("self_get_status_message")

function Tox:friends_update()
   local ret, n = {}, self:self_get_friend_list_size()
   local list = ffi.new("uint32_t[?]", n)
   self:_self_get_friend_list(list)
   local i = 0 
   while i < n do
      self.friends[list[i]] = ToxFriend.new{fid=list[i], tox=self}
      i = i + 1
   end
   return self.friends
end
Tox_ret_via_arg("", "uint32_t[?]")

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

function Tox:update_callback(name, set_fun)
   local cb_n = "cb_" .. name
   self[cb_n] = self[cb_n] or set_fun
   self["callback_" .. name](self, self[cb_n], nil)
end

-- Note: can skip some work if none of the friends are treated differently.
function Tox:update_friend_callback(name, set_fun)
   local own_cb = self["cb_friend_" .. name] or set_fun
   self["cb_friend_" .. name] = own_cb
   local function cb(itself, fid, ...)
      local friend = self.friends[fid]
      local friend_cb = friend and friend["cb_" .. name]
      if friend_cb then
         friend_cb(friend, ...)
      end
      if own_cb then
         own_cb(self, friend, ...)
      end
   end
   self["callback_friend_" .. name](self, cb, nil)
end

--   callback_friend_name = false,
--   callback_friend_status_message = false,
--   callback_friend_status = false,
--   callback_friend_connection_status = false,
--   callback_friend_typing = false,
--   callback_friend_read_receipt = false,
--   callback_friend_request = false,
--   callback_friend_message = false,

local function readall(fd)
   local ret, more = "", fd:read(1024)
   while more do
      ret = ret .. more
      more = fd:read(1024)
   end
   return ret
end

function Tox:default_bootstrap()
   local option_list = require "tox_comms.data.settings"
   local use = option_list[math.random(#option_list)]
   -- TODO is this sufficient? No need to keep trying?
   self:bootstrap(use.address, tonumber(use.port), use.userId, nil)
end

Tox.pubkey_name = "default"

local lfs = require "lfs"  -- Dont understand why no `os.mkdir`

function Tox.new(self)
   self = setmetatable(self, Tox)
   self:init()
   return self
end

-- Will use the name to get the current one if needed.
function Tox:init()
   local opts = nil
   if self.savedata_file then
      if self.savedata_file == true then
         local dirname = self.dirname or
            os.getenv("HOME") .. "/.tox_comms/" .. self.pubkey_name
         lfs.mkdir(dirname)
         self.savedata_file = dirname .. "/savedata"
      end
      local fd = io.open(self.savedata_file)
      if fd then
         opts = raw.tox_options_new(nil)
         opts.savedata_type = 1  -- TOX_SAVEDATA_TYPE_TOX_SAVE
         local got = readall(fd)
         opts.savedata_length = #got
         opts.savedata_data = to_c.str(got)
         fd:close()
      end
   end
   self.cdata = raw.tox_new(opts, data, len or 0, err)
   self.friends = {}
   if opts then
      self:friends_update()
   else
      if self.auto_bootstrap then
         self:default_bootstrap()
      end
   end
   self:self_set_name(self.name or "(unnamed)")
   return self
end

function Tox:write_savedata(to_file)
   local to_file = to_file or self.savedata_file
   to_file = (to_file ~= true and to_file) or getenv("HOME") .. "/.tox_comms/savedata"
   local fd = io.open(to_file, "w")
   if fd then
      fd:write(self:get_savedata())
      fd:close()
      return to_file
   else
      return false
   end
end

function Tox:loop()
   local socket = require "socket"
   while true do
      self:iterate()
      socket.sleep(self:iteration_interval()/1000.0)
   end
end

return Tox
