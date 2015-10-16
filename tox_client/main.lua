-- Req local.
local function req(what) return require("tox_client." .. what) end

local EdgeChat = require "tox_comms.EdgeChat"
local edgechat = EdgeChat:new{ Edge=req "Edge" }

local tox = require("tox_comms.do.Tox"):new{ savedata_file=true, edgechat=edgechat }

if arg[1] then
   print("Adding friend", arg[1], "to", tox:addr(),
         tox:add_friend(arg[1], "Yello"))
end

local edge_toxes = { tox, }

local addrs = {}
for _, el in ipairs(edge_toxes) do
   el:save()  -- Save while at it.
   table.insert(addrs, el:addr())
end

print "Making pages"
local server = require("page_html.serve.pegasus"):new()

local function mkpg(name)
   return req(name):new{edge_toxes = edge_toxes, edgechat = edgechat }
end

server:add(mkpg "Aliasses")
server:add(mkpg "Contacts")
server:add(mkpg "Chat")

print("Starting server")
server:prepare()

print(string.format("Server ready to go on http://%s:%s", server.server:getsockname()))
print("Starting Tox loop")
local sleep = require("socket").sleep
while true do
   tox:iterate()
   server.server:settimeout(tox:iteration_interval()/1000.0, 'b')
   server:iterate()
end

print("Asked to quit, saving")
for _, el in ipairs(edge_toxes) do el:save() end
