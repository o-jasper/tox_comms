--  Copyright (C) 02-09-2016 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

-- TODO no self-storing..

local ffi = require "ffi"

local This = require("nunix.Class"):class_derive{ __name="Tox.Bare" }
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
This.bootstrap_options = require "Tox.data.settings"

function This:default_bootstrap(index)
   local list = self.bootstrap_options
   local index = index or math.random(#list)
   local use = list[index]

   local err_into = ffi.new("int[1]")
   local ret = self:bootstrap(use.address,
                              tonumber(use.port), to_c.bin(use.userId), err_into)
   print("Tried " .. index, use.address, ret, err_into[1])
   return ret, err_into[1], use
end

function This:init()
   self.addr2fid, self.fid2addr = {}, {}  -- Addresses to fids and back

   -- savedata can be filled with .. the savedata to use as private key.
   --  self:savedata gets that data.
   local opts = self.opts
   --assert(opts or self.savedata)
   if self.savedata then
      opts = raw.tox_options_new(nil)
      opts.savedata_type = 1  -- TOX_SAVEDATA_TYPE_TOX_SAVE
      opts.savedata_length = #self.savedata
      opts.savedata_data = to_c.str(self.savedata)
   end
   self.cdata = raw.tox_new(opts, nil)

   if not opts and self.auto_bootstrap then
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
   local fid, err = self.addr2fid[addr], nil
   if not fid or fid == 4294967295 then
      -- Could be that we saw pubkey before, in that case, set it to the full address.
      fid = self.addr2fid[string.sub(addr, 1,64)]
      if not fid or fid == 4294967295 then
         local err_into = ffi.new("int[1]")
         fid = raw.tox_friend_add_norequest(self.cdata, to_c.bin(addr), err_into)
         err = err_into[1]
      end
      biject_fid_addr(self, fid, addr)
   end
   -- TODO with all these err thingies, also give more info.
   -- Recognize errors by their ID and pointer to table.
   return fid, err
end

This.default_friend_request_msg = "No message"
function This:friend_request(addr, comment)
   local comment = comment or self.default_friend_request_msg
   local c_comment = to_c.str(comment)
   local c_addr     =to_c.bin(assert(addr, "No addr?"))
   local err_into = ffi.new("int[1]")
   local fid = raw.tox_friend_add(self.cdata, c_addr, c_comment, #comment + 1, err_into)
   biject_fid_addr(self, fid, addr)
   return fid, err_into[1]
end

function This:raw_send_message(fid, message, kind)
   raw.tox_friend_send_message(self.cdata, fid, kind or 0,
                               to_c.str(message), #message, nil)
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

def_sized("name", "tox_self_get_name")
def_sized("status_message", "tox_self_get_status_message")
def_sized("get_savedata", "tox_get_savedata")

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

   self_set_status_message = "set_status_message",

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

--   iterate = "step",
   iteration_interval = "step_interval",

--   add_groupchat = false,
}
function This:step()
   raw.tox_iterate(self.cdata, nil)
end

-- Copy-in either raw or use provided name.
for k, rename in pairs(tox_funlist) do
   local fun = raw["tox_" .. k]
   This[rename or k] = function(self, ...) return fun(self.cdata, ...) end
end

-- TODO which others need better treatment..
function This:set_name(to, err)
   return raw.tox_self_set_name(self.cdata, to, #to, err or nil)
end
function This:set_status_message(to, err)
   return raw.tox_self_set_status_message(self.cdata, to, #to, err or nil)
end

function This:set_callback(cb_name, set_fun)
   raw["tox_callback_" .. cb_name](self.cdata, set_fun)
end

local function first_ffi_str(str, sz, ...)
   return ffi.string(str,sz), ...
end

function This:set_friend_callback(cb_name, set_fun)
   local argsfix = {  -- Messes with arguments lua-izing them a bit.
      name = first_ffi_str, status_message = first_ffi_string,
      message = function(kind, msg, msg_sz, ...) return kind, ffi.string(msg, msg_sz), ... end,
   }
   local af, set_cb = argsfix[cb_name], assert(raw["tox_callback_friend_" .. cb_name])
   if af then
      local function cb(tox_cdata, fid, ...)
         set_fun(tox_cdata, fid, af(...))
      end
      set_cb(self.cdata, cb)
   else
      set_cb(self.cdata, set_fun)
   end
end

function This:set_group_callback(cb_name, set_fun)
   local function cb(tox_cdata, gid, peernumber, ...)
      group["cb_" .. cb_name](gid, peernumber, ...)
   end
   raw["tox_callback_group_" .. cb_name](self.cdata, cb, nil)
end

return This
