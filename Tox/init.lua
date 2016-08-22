--  Copyright (C) 22-08-2016 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

-- TODO no self-storing..

local ffi = require "ffi"

local This = require("nunix.Class"):class_derive{ __name="ffi.Tox" }
local raw = require "Tox.ffi.raw"
local to_c = require "Tox.ffi.to_c"

local consts = {
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

This.consts = consts
local option_list = require "Tox.data.settings"

function This:default_bootstrap()
   local use = option_list[math.random(#option_list)]
   -- TODO is this sufficient? No need to keep trying?
   self:bootstrap(use.address, tonumber(use.port), use.userId, nil)
end

function This:init()
   self.fid2addr = {}  -- Fids to addresses.
   self.addr2fid = {}

   local opts = self.opts
   assert(opts or self.savedata)
   if savedata then
      opts = raw.tox_options_new(nil)
      opts.savedata_type = 1  -- TOX_SAVEDATA_TYPE_TOX_SAVE
      opts.savedata_length = #self.savedata
      opts.savedata_data = to_c.str(self.savedata)
   end
   self.cdata = raw.tox_new(opts, nil)

   if not opts and self.auto_bootstrap then  -- TODO do we know nodes already?
      self:default_bootstrap()
   end   
end

local sleep = require("socket").sleep
-- Start the loop for Tox to do its thing.
function This:loop()
   while true do
      self:step()
      sleep(self:step_interval()/1000.0)
   end
end

-- Keeping track of addresses.
local function biject_fid_addr(self, fid, addr)
   self.fid2addr[fid]  = addr
   self.addr2fid[addr] = fid
end

function This:ensure_addr(fid)
   local addr = self.fid2addr[fid]
   if not addr then
      local ret = ffi.new("uint8_t[?]", 32)
      raw.tox_friend_get_public_key(self.cdata, fid, ret, nil)
      addr = to_c.enhex(ret, 32)
      biject_fid_addr(self, fid, addr)
   end
   return addr
end

function This:ensure_fid(addr)
   local fid = self.addr2fid[addr]
   if not fid or fid == 4294967295 then
      -- Could be that we saw pubkey before, in that case, set it to the full address.
      fid = self.addr2fid[string.sub(addr, 1,64)]
      if not fid or fid == 4294967295 then
         fid = raw.tox_friend_add_norequest(self.cdata, to_c.bin(addr), nil)
      end
      biject_fid_addr(self, fid, addr)
   end
   return fid
end

This.default_friend_request_msg = "No message"
function This:friend_request(addr, comment)
   local c_comment = to_c.str(comment or self.default_friend_request_msg)
   local c_addr    = to_c.bin(addr)
   local fid = raw.tox_friend_add(self.cdata, c_addr, c_comment, #comment, nil)
   biject_fid_addr(self, fid, addr)
end

function This:send_message(to_addr, message, kind)
   local fid = self:ensure_fid(to_addr)
   raw.tox_friend_send_message(self.cdata, fid, kind or 0,
                               to_c.str(message), #message, nil)
end

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
   This[name] = ret_sized(raw, name, ...)
end

def_sized("get_name", "tox_self_get_name")
def_sized("status_message", "tox_self_get_status_message")
def_sized("savedata", "tox_get_savedata")

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
   This[name] = function(name, ...)
      return to_c.enhex(ret_arg(name, ...), sz)
   end
end
-- Get at data.
def_arg_enhex("addr",    "tox_self_get_address",    consts.ADDRESS_SIZE)
def_arg_enhex("pubkey",  "tox_self_get_public_key", consts.SECRET_KEY_SIZE)
def_arg_enhex("privkey", "tox_self_get_secret_key", consts.PUBLIC_KEY_SIZE)

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

   iterate = "step",
   iteration_interval = "step_interval",

   add_groupchat = false,
}
-- Copy-in either raw or use provided name.
for k, rename in pairs(tox_funlist) do
   local fun = raw["tox_" .. k]
   This[rename or k] = function(self, ...) return fun(self.cdata, ...) end
end

-- TODO which others need better treatment..
function This:set_name(to, err)
   return raw.tox_self_set_name(self.cdata, to, #to, err or nil)
end


function This:update_callback(cb_name, set_fun)
   raw["tox_callback_" .. cb_name](self.cdata, set_fun, nil)
end

function This:update_friend_callback(cb_name, set_fun)
   local argsfix = {
      name = ffi.string, status_message=ffi.string,
      message = function(kind, msg, msg_sz) return kind, ffi.string(msg, msg_sz) end,
   }
   local af = argsfix[cb_name]
   if af then
      local function cb(tox_cdata, fid, ...)
         set_fun(tox_cdata, fid, af(...))
      end
      raw["tox_callback_friend_" .. cb_name](self.cdata, cb, nil)
   else
      raw["tox_callback_friend_" .. cb_name](self.cdata, set_fun, nil)
   end
end

function This:update_group_callback(cb_name, set_fun)
   local function cb(tox_cdata, gid, peernumber, ...)
      group["cb_" .. cb_name](gid, peernumber, ...)
   end
   raw["tox_callback_group_" .. cb_name](self.cdata, cb, nil)
end

return This
