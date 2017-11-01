--  Copyright (C) 19-08-2017 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

-- Takes over some of the callbacks doing it via an events system instead.

local Bare = require "Tox.Bare"
local This = Bare:class_derive{ __name="Tox.Evented" }

local ffi = require "ffi"
local raw = require "Tox.ffi.raw"
local ffi_events = require "Tox.ffi.events"

function This:init()
   Bare.init(self)
   self.callbacks = {}
   self.cevents = ffi_events.new_ToxEvents(self.cdata)
   ffi_events.ToxEvents_register_callbacks(self.cevents)
end

This.cb_names = {}
for _, k in ipairs{
   "self_connection_status",
   "friend_connection_status", "friend_status", "friend_status_message", "friend_name",
   "friend_request", "friend_message", "friend_typing",
                  } do
   This.cb_names[ffi_events["Ev_" .. k]] = k
end

function This:set_callback(cb_name, set_fun)
   self.callbacks[ffi_events["Ev_" .. cb_name]] = set_fun
end
function This:set_friend_callback(cb_name, set_fun)
   print(ffi_events["Ev_friend_" .. cb_name])
   self.callbacks[ffi_events["Ev_friend_" .. cb_name]] = set_fun
end

local function connstat(cb, ev) cb(ev.connection_status) end
local cb_funs = {
   [ffi_events.Ev_dud] = function() error("shouldnt happen") end,

   [ffi_events.Ev_self_connection_status] = connstat,

   [ffi_events.Ev_friend_connection_status] = connstat,
   [ffi_events.Ev_friend_status] = function(cb, ev) cb(ev.status) end,
   [ffi_events.Ev_friend_status_message] = function(cb, ev)
      cb(ev.friend_number, ffi.string(ev.message, ev.length))
   end,
   [ffi_events.Ev_friend_name] = function(cb, ev)
      cb(ev.friend_number, ffi.string(ev.name, ev.length))
   end,
   [ffi_events.Ev_friend_request] = function(cb, ev)
      cb(ev.friend_number, ffi.string(ev.message, ev.length))
   end,

   [ffi_events.Ev_friend_message] = function(cb, ev)
      cb(ev.friend_number, ev.type, ffi.string(ev.message, ev.length))
   end,
   [ffi_events.Ev_friend_typing] = function(cb, ev)
      cb(ev.friend_number, ev.is_typing);
   end,
}

function This:step()
   ffi_events.ToxEvents_iterate(self.cevents)
   -- Poll all the events inbetween.
   while true do  -- TODO ugh bit of a pita.
      local ev = ffi_events.ToxEvents_poll(self.cevents)
      if ev.tp == ffi_events.Ev_dud then  -- A duds means hit the end.
         return
      else
         local tp = tonumber(ev.tp)
         local cb = self.callbacks[tp]  -- If callback, use.
         if cb then
            assert(cb_funs[tp], "Missing handler; " .. tp)(cb, ev)
         else
            print("no cb", tp, self.cb_names[tp])
         end
      end
   end
end

return This
