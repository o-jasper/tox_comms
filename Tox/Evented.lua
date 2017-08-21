--  Copyright (C) 19-08-2017 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

-- Takes over some of the callbacks doing it via an events system instead.

local Bare = require "Tox.Bare"
local This = Bare:class_derive{ __name="Tox.Evented" }

require "Tox.ffi.raw"
local ffi_events = require "Tox.ffi.events"

function This:init()
   Bare.init(self)
   self.callbacks = {}
   self.cevents = ffi_events.new_ToxEvents(self.cdata)
   ffi_events.ToxEvents_register_callbacks(self.cevents)
end

local raw = require "Tox.ffi.raw"

function This:set_callback(cb_name, set_fun)
   self.callbacks[cb_name] = set_fun
end

function This:set_friend_callback(cb_name, set_fun)
   self.callbacks["friend_" .. cb_name] = set_fun
end

local ffi = require "ffi"

function This:step()
   ffi_events.ToxEvents_iterate(self.cevents)
   -- Poll all the events inbetween.
   while true do  -- TODO ugh bit of a pita.
      local ev = ffi_events.ToxEvents_poll(self.cevents)
      if ev.tp == ffi_events.Ev_dud then  -- A duds means hit the end.
         return
      elseif ev.tp == ffi_events.Ev_friend_request then
         local cb = self.callbacks.friend_request 
         if cb then
            cb(ev.friend_number, ffi.string(ev.message, ev.length))
         end
      elseif ev.tp == ffi_events.Ev_friend_message then
         local cb = self.callbacks.friend_message
         if cb then
            cb(ev.friend_number, ev.type, ffi.string(ev.message, ev.length))
         end
      end
   end
end

return This
