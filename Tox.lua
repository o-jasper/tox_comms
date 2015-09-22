--  Copyright (C) 07-09-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local ffi = require "ffi"
local to_c = require "tox_comms.ffi.to_c"

local ToxFriend = require "tox_comms.ToxFriend"

local raw = require "tox_comms.ffi.raw"

local Tox = {
   __name = "FFI_Tox",
   PUBLIC_KEY_SIZE = 32,
   SECRET_KEY_SIZE = 32,
   ADDRESS_SIZE = 38,
   MAX_NAME_LENGTH = 128,
   MAX_STATUS_MESSAGE_LENGTH = 1007,
   MAX_FRIEND_REQUEST_LENGTH = 1016,
   MAX_MESSAGE_LENGTH = 1372,
   MAX_CUSTOM_PACKET_SIZE = 1373,
   HASH_LENGTH = 32,
   FILE_ID_LENGTH = 32,
   MAX_FILENAME_LENGTH = 255,
}
Tox.__index  = Tox

local function ret_sized(from_raw, name, rawname, ctp, szname)
   local rawname = rawname or "tox_" .. name
   local szname  = szname or rawname and rawname .. "_size"
   local ctp = ctp or "char[?]"
   return function(self)
      local sz = from_raw[szname](self.cdata)
      local ret = ffi.new(ctp, sz)
      from_raw[rawname](self.cdata, ret)
      return ffi.string(ret, sz)
   end
end

local function def_sized(name, ...)
   Tox[name] = ret_sized(raw, name, ...)
end

def_sized("name", "tox_self_get_name")
def_sized("status_message", "tox_self_get_status_message")
def_sized("savedata", "tox_get_savedata")

local function ret_set_sized(from_raw, name, rawname, ctp)
   local rawname = rawname or "tox_" .. name
   return function(self, to, size, err)
      return from_raw[rawname](self.cdata, to, size or #to, err)
   end
end
local function def_set_sized(name, ...)
   Tox[name] = ret_set_sized(raw, name, ...)
end
def_set_sized("set_name", "tox_self_set_name")
def_set_sized("set_status_message", "tox_self_set_status_message")

local function ret_arg(from_raw, name, rawname, sz, ctp)
   local rawname = rawname or "tox_" .. name
   local ctp = ctp or string.format("uint8_t[%d]", sz)
   assert(sz)
   return function(self)
      local ret = ffi.new(ctp)
      from_raw[rawname](self.cdata, ret)
      return ffi.string(ret, sz)
   end
end

local function def_arg_enhex(name, rawname, sz, ...)
   local ret_arg = ret_arg(raw, name, rawname, sz, ...)
   Tox[name] = function(name, ...)
      return to_c.enhex(ret_arg(name, ...), sz)
   end
end
def_arg_enhex("addr", "tox_self_get_address", Tox.ADDRESS_SIZE)
def_arg_enhex("pubkey", "tox_self_get_public_key", Tox.SECRET_KEY_SIZE)
def_arg_enhex("privkey", "tox_self_get_secret_key", Tox.PUBLIC_KEY_SIZE)

local tox_funlist = {
   bootstrap = false,
   self_get_connection_status = "connection_status",
   self_get_status = "status",
   self_set_status = "set_status",

   self_get_nospam = "nospam",
   self_set_nospam = "set_nospam",

   get_savedata_size = false,

   self_get_friend_list_size = "friend_cnt",

   self_set_typing = "set_typing",

   add_tcp_relay = false,
   file_control = false,
   file_seek = false,
   file_get_file_id = false,
   file_send = false,
   file_send_chunk = false,
   self_get_udp_port = "udp_port",
   self_get_tcp_port = "tcp_port",

-- Set via `raw` or `update_.._callback`
--   callback_self_connection_status = false,
--   callback_friend_name = false,
--   callback_friend_status_message = false,
--   callback_friend_status = false,
--   callback_friend_connection_status = false,
--   callback_friend_typing = false,
--   callback_friend_read_receipt = false,
--   callback_friend_request = false,
--   callback_friend_message = false,
--   callback_file_recv_control = false,
--   callback_file_chunk_request = false,
--   callback_file_recv = false,
--   callback_file_recv_chunk = false,
--   callback_friend_lossy_packet = false,
--   callback_friend_lossless_packet = false,

   iterate = false,
   iteration_interval = false,

   add_groupchat = false,
}

-- Copy-in either raw or 
for k, rename in pairs(tox_funlist) do
   local fun = raw["tox_" .. k]
   Tox[rename or k] = function(self, ...) return fun(self.cdata, ...) end
end

function Tox:_add_friend_fid(fid)
   local friend = ToxFriend:new{fid=fid, tox=self}
   self.friends[fid] = friend
   return friend
end

Tox.default_add_friend_msg = "No message"
function Tox:add_friend(addr, comment)
   local addr, _comment = to_c.addr(addr), to_c.str(comment or self.default_add_friend_msg)
   local fid = raw.tox_friend_add(self.cdata, addr, _comment, #comment, nil)
   return self:_add_friend_fid(fid)
end

function Tox:add_friend_norequest(addr)
   local addr = to_c.addr(addr)
   local fid = raw.tox_friend_add_norequest(self.cdata, addr, nil)
   return self:_add_friend_fid(fid)
end

function Tox.friend_by_pubkey(pubkey)
   local fid = raw.tox_friend_by_public_key(self.cdata, to_c.addr(pubkey))
   return self.friends[fid] or self:_add_friend_fid(fid)
end

function Tox:friends_update()
   local ret, n = {}, self:friend_cnt()
   local list = ffi.new("uint32_t[?]", n)
   raw.tox_self_get_friend_list(self.cdata, list)
   local i = 0 
   while i < n do
      assert(self)
      self.friends[list[i]] = ToxFriend:new{fid=list[i], tox=self}
      i = i + 1
   end
   return self.friends
end

function Tox:update_callback(name, set_fun)
   local cb_n = "cb_" .. name
   self[cb_n] = self[cb_n] or set_fun
   raw["tox_callback_" .. name](self.cdata, self[cb_n], nil)
end

-- Note: can skip some work if none of the friends are treated differently.
function Tox:update_friend_callback(name, set_fun)
   local own_cb = self["cb_friend_" .. name] or set_fun
   self["cb_friend_" .. name] = own_cb
   local friends_dict = self.friends
   local function cb(tox_cdata, fid, ...)
      local friend = friends_dict[fid]
      local friend_cb = friend and friend["cb_" .. name]
      if friend_cb then
         friend_cb(friend, ...)
      end
      if own_cb then
         own_cb(self, friend, ...)
      end
   end
   raw["tox_callback_friend_" .. name](self.cdata, cb, nil)
end

function Tox:update_group_callback(name, set_fun)
   local group_dict = self.groups

   local function cb(tox_cdata, group_id, peernumber, ...)
      local group = group_dict[group_id]
      if group then
         local friend = group.friends[peernumber]
         group["cb_" .. name](group, friend, ...)
      end
   end
   self["callback_group_" .. name](self, cb, nil)
end

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

function Tox:new(new)
   new = setmetatable(new, self)
   new:init()
   return new
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
   self.cdata = raw.tox_new(opts, nil)

   self.friends = {}
   if opts then
      self:friends_update()
   else
      if self.auto_bootstrap then
         self:default_bootstrap()
      end
   end
   self:set_name(self.use_name or self.name or "(unnamed)")
   return self
end

function Tox:write_savedata(to_file)
   local to_file = to_file or self.savedata_file
   to_file = (to_file ~= true and to_file) or getenv("HOME") .. "/.tox_comms/savedata"
   local fd = io.open(to_file, "w")
   if fd then
      fd:write(self:savedata())
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
