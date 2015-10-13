--  Copyright (C) 08-10-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local ffi = require "ffi"
local raw = require "tox_comms.ffi.raw"
local to_c = require "tox_comms.ffi.to_c"

local Bare = require "tox_comms.do.Tox.Bare"

local This = {}
for k,v in pairs(Bare) do This[k] = v end
This.__index = This

function This:init()
   Bare.init(self)

   local edgechat, addr = assert(self.edgechat), self:addr()
   edgechat.doers[addr] = self

   -- Put in place callbacks that tell the edges stuff bafter receiving.
   local function claim(claim_name)
      return function(cdata, fid, ...)
         edgechat:ensure_edge(addr, self:ensure_addr(fid)):see_claim(nil, claim_name, ...)
      end
   end
   self:update_friend_callback("name",              claim("name"))
   self:update_friend_callback("status_message",    claim("status_message"))
   self:update_friend_callback("status",            claim("status"))
   self:update_friend_callback("typing",            claim("typing"))
   self:update_friend_callback("connection_status", claim("connection_status"))

   local function message(cdata, fid, kind, msg)
      edgechat:ensure_edge(addr, self:ensure_addr(fid)):see_msg(nil, kind, msg)
   end
   self:update_friend_callback("message", message)

   local function friend_request(cdata, from_addr, msg, msg_sz)
      self:add_friend_norequest(from_addr)
      edgechat:ensure_edge(addr, from_addr):see_friend_request(nil, ffi.string(msg, msg_sz))
   end
   self:update_callback("friend_request", friend_request)
end

function This:do_claim(to, i, name, what)
   -- NOTE: not particular to other side.
   if name == "status_message" then
      assert(type(what) == "string")
      raw.tox_self_set_status_message(self.cdata, what, #what, nil)
   elseif name == "name" then
      assert(type(what) == "string")
      raw.tox_self_set_name(self.cdata, what, #what, nil)
   else
      print("Dunno how to do", name)
   end
end

function This:add_friend(addr, msg)
   Bare.add_friend(self, addr, msg)
   self.edgechat:ensure_edge(self:addr(), addr)
end

function This:do_msg(to_addr, i, kind, message)
   local fid = self:ensure_fid(to_addr)
   raw.tox_friend_send_message(self.cdata, fid, kind or 0,
                               to_c.str(message), #message, nil)
end

return This
