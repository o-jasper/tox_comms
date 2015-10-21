local ffi = require "ffi"
local raw = require "tox_comms.ffi.raw"
local to_c = require "tox_comms.ffi.to_c"

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

local Bare = {}
Bare.__index = Bare

Bare.consts = consts

function Bare:new(new)
   new = setmetatable(new, self)
   new:init()
   return new
end

function Bare:default_bootstrap()
   local option_list = require "tox_comms.data.settings"
   local use = option_list[math.random(#option_list)]
   -- TODO is this sufficient? No need to keep trying?
   self:bootstrap(use.address, tonumber(use.port), use.userId, nil)
end

local lfs = require "lfs"  -- Dont understand why no `os.mkdir`

Bare.pubkey_name = "default"

local function proper_io_lines(file)
   local fd = io.open(file)
   if fd then
      fd:close()
      return io.lines(file)
   else
      return ipairs{}
   end
end

function Bare:init()
   self.fid2addr = {}  -- Fids to addresses.
   self.addr2fid = {}

   self.dir = self.dir or os.getenv("HOME") .. "/.tox_comms/" .. self.pubkey_name
   lfs.mkdir(self.dir)

   local opts = nil
   if self.savedata_file then
      if self.savedata_file == true then
         self.savedata_file = self.dir .. "/savedata"
      end
      local fd = io.open(self.savedata_file)
      if fd then
         opts = raw.tox_options_new(nil)
         opts.savedata_type = 1  -- TOX_SAVEDATA_TYPE_TOX_SAVE
         local got = fd:read("*a")
         opts.savedata_length = #got
         opts.savedata_data = to_c.str(got)
         fd:close()
      end
   end
   self.cdata = raw.tox_new(opts, nil)

   if self.friend_list_file then
      if self.friend_list_file == true then
         self.friend_list_file = self.dir .. "/friend_list.txt"
      end
      for addr in proper_io_lines(self.friend_list_file) do
         self:ensure_fid(addr)
      end
   end

   if not opts and self.auto_bootstrap then  -- TODO do we know nodes already?
      self:default_bootstrap()
   end
end


function Bare:write_savedata(to_file)
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

function Bare:save()
   -- Savedata.
   self:write_savedata(self.savedata_file)

   -- Friend list.
   local fd = io.open(self.friend_list_file, "w")
   for addr, _ in pairs(self.addr2fid) do
      fd:write(addr .. "\n")
   end
   fd:close()
end

-- Start the loop for Tox to do its thing.
function Bare:loop()
   local sleep = require("socket").sleep
   while true do
      self:iterate()
      sleep(self:iteration_interval()/1000.0)
   end
end

local function biject_fid_addr(self, fid, addr)
   self.fid2addr[fid]  = addr
   self.addr2fid[addr] = fid
end

function Bare:ensure_addr(fid)
   local addr = self.fid2addr[fid]
   if not addr then
      local ret = ffi.new("uint8_t[?]", 32)
      raw.tox_friend_get_public_key(self.cdata, fid, ret, nil)
      addr = to_c.enhex(ret, 32)
      biject_fid_addr(self, fid, addr)
   end
   return addr
end

function Bare:ensure_fid(addr)
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

Bare.default_friend_request_msg = "No message"
function Bare:friend_request(addr, comment)
   local c_comment = to_c.str(comment or self.default_friend_request_msg)
   local c_addr    = to_c.bin(addr)
   local fid = raw.tox_friend_add(self.cdata, c_addr, c_comment, #comment, nil)
   biject_fid_addr(self, fid, addr)
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
   Bare[name] = ret_sized(raw, name, ...)
end

def_sized("name", "tox_self_get_name")
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
   Bare[name] = function(name, ...)
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

   iterate = false,
   iteration_interval = false,

   add_groupchat = false,
}
-- Copy-in either raw or use provided name.
for k, rename in pairs(tox_funlist) do
   local fun = raw["tox_" .. k]
   Bare[rename or k] = function(self, ...) return fun(self.cdata, ...) end
end

function Bare:update_callback(cb_name, set_fun)
   raw["tox_callback_" .. cb_name](self.cdata, set_fun, nil)
end

function Bare:update_friend_callback(cb_name, set_fun)
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

function Bare:update_group_callback(cb_name, set_fun)
   local function cb(tox_cdata, gid, peernumber, ...)
      group["cb_" .. cb_name](gid, peernumber, ...)
   end
   raw["tox_callback_group_" .. cb_name](self.cdata, cb, nil)
end

return Bare
