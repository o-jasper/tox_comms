local PrevEdge = require "tox_comms.EdgeChat.Edge"
local gettime  = require("socket").gettime

local This = {}
for k,v in pairs(PrevEdge) do This[k] = v end
This.__index = This

This.keep_time = 3600*24

function This:init()
   self.events = self.events or {}

   PrevEdge.init(self)
end

-- Remove events that are no longer to be kept.
function This:clean_events(t)
   if self.keep_time then
      local t, events = t or gettime(), self.events
      while #events > 0 and events[1].time > t + self.keep_time do
         table.remove(events, 1)
      end
   end
end

local function mk_see(name)
   local fullname = "see_" .. name
   This[fullname] = function(self, i, ...)
      local rest = {}
      for _,el in ipairs{...} do
         table.insert(rest, tonumber(el) or tostring(el))
      end
      table.insert(self.events, { tp = name, time = gettime(), i = i or false, rest = rest})
      self:clean_events()
   end
end
mk_see("msg")
mk_see("missed")
mk_see("friend_request")
mk_see("claim")

local function mk_do(name)
   local fullname = "do_" .. name
   This[fullname] = function(self, i, ...)
      table.insert(self.events, { tp = name, time = gettime(), i = i, rest = {...}})  -- Log
      self:clean_events()
      PrevEdge[fullname](self, i, ...)  -- Also actually do.
   end
end

mk_do("msg")
mk_do("friend_request")

function This:list_events_after(t)
   local ret = {}
   for _, el in ipairs(self.events) do
      if el.time > t then table.insert(ret, el) end
   end
   return ret
end

return This
