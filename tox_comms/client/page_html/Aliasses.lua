
local Edge = require "tox_comms.client.page_html.Edge"

local Assets = require "page_html.Assets"

local Page = {}
Page.__index = Page

Page.name = "aliasses"
Page.where = { "tox_comms/client/page_html/" }

--Page.Edge = require "tox_comms.client.page_html.Edge"

function Page:new(new)
   new = setmetatable(new or {}, self)
   new:init()
   return new
end

function Page:init(new)
   self.edgechat = self.edgechat
   self.edge_toxes = self.edge_toxes or {}
   self.routines = {}
   --TODO need sub-page for each edge..
end

function Page:repl(state)
   local what, rest = string.match(state.rest_path or "/", "^/(?[%w]+)/?(.+)$")
   if what == "chat" then
      local fa, ta = string.match(rest, "([%x]+)/([%x]+)/?")
      return { from_addr = fa, to_addr = ta }
   elseif what == "contacts" then
      local fa = rest
      assert(string.match(fa, "[%x]+/?"))
      return { from_addr = fa }
   else  -- Aliases.
      return {}
   end
end

local function edge(self, from_addr, to_addr)
   return self.edgechat:ensure_edge(from_addr, to_addr)
end

-- RPC functions.
local rpc_js = {}
Page.rpc_js = rpc_js

function rpc_js:tox_addrs()
   return function()
      local ret = {}
      for _, el in ipairs(self.edge_toxes) do table.insert(ret, el:addr()) end
      return ret
   end
end

function rpc_js:contacts(fa)
   return function()
      local ret = {}
      for addr in pairs(self.edgechat:ensure_from(fa)) do table.insert(ret, addr) end
      return ret
   end
end

function rpc_js:contacts_more(fa)
   return function()
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
function rpc_js:list_events_after(fa, ta, after_t)
   return function()
      return edge(self, fa, ta):list_events_after(after_t)
   end
end

function rpc_js:list_events_all(fa, ta)
   return function()
      return edge(self, fa, ta).events
   end
end

-- Sending events.
function rpc_js:do_msg(fa,ta, ...)
   local inp =  {...}
   return function()
      return edge(fa, ta):do_msg(unpack(inp))
   end
end
function rpc_js:do_friend_request(fa,ta, ...)
   local inp = {...}
   return function()
      return edge(fa, ta):do_friend_request(unpack(inp))
   end
end

return Page
