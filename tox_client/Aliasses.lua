local Page = {}
for k,v in pairs(require "tox_client.BasePage") do Page[k] = v end
Page.__index = Page

Page.name = "aliasses"

function Page:repl(state) return {} end

local rpc_js = require "tox_client.rpc_js"
Page.rpc_js = {}
for _, name in ipairs{"tox_addrs"} do Page.rpc_js[name] = rpc_js[name] end

return Page
