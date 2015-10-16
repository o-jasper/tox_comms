local function edge(self, from_addr, to_addr)
   return self.edgechat:ensure_edge(from_addr, to_addr)
end

local rpc_js = {}

function rpc_js:tox_addrs()
   return function()
      local ret = {}
      for _, el in ipairs(self.edge_toxes) do table.insert(ret, el:addr()) end
      return ret
   end
end

function rpc_js:contacts()
   return function(fa)
      local ret = {}
      for addr in pairs(self.edgechat:ensure_from(fa)) do table.insert(ret, addr) end
      return ret
   end
end

function rpc_js:contacts_more()
   return function(fa)
      local ret = {}
      for addr, edge in pairs(self.edgechat:ensure_from(fa)) do
         table.insert(ret, {addr, edge.claims})
      end
      return ret
   end
end

-- Getting info on edge.
function rpc_js:claims(fa, ta) return function() return edge(self, fa,ta).claims end end

-- Listing events.
function rpc_js:list_events_after()
   return function(fa, ta, after_t)
      return edge(self, fa, ta):list_events_after(after_t)
   end
end

function rpc_js:list_events_all()
   return function(fa, ta)
      return edge(self, fa, ta).events
   end
end

-- Sending events.
function rpc_js:do_msg()
   return function(fa,ta, ...)
      return edge(fa, ta):do_msg(...)
   end
end
function rpc_js:do_friend_request()
   return function(fa,ta, ...)
      return edge(fa, ta):do_friend_request(...)
   end
end

return rpc_js
