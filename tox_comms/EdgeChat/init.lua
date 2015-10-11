
local This = {}
This.__index = This

This.Edge = require "tox_comms.EdgeChat.Edge"

function This:new(new)
   new = setmetatable(new, self)
   new:init()
   return new
end

function This:init()
   self.edges = self.edges or {}
   self.doers = self.doers or {}
end

function This:ensure_from(from_addr)
   local edges = self.edges
   local dict = edges[from_addr]
   if not dict then
      if dict == false then return false end
      dict = {}
      edges[from_addr] = dict
   end
   return dict
end

function This:ensure_edge(from_addr, to_addr, Creator)
   local dict = self:ensure_from(from_addr)

   local e = dict[to_addr]
   if not e then
      if e == false then return false end
      assert(to_addr)
      e = (Creator or self.Edge):new{from_addr = from_addr, addr = to_addr, 
                                     doer = self.doers[from_addr]}
      dict[to_addr] = e
   end
   return e
end

function This:block(from_addr, to_addr, to)
   if to == nil then to = false end
   if not to_addr then self.edges[from_addr] = to end
   local dict = ensure_from(self.edges, from_addr)
   dict[to_addr] = to
end

return This
