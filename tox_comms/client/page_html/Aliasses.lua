local Page = {}
for k,v in pairs(require "tox_comms.client.page_html.BasePage") do Page[k] = v end
Page.__index = Page

Page.name = "aliasses"
Page.where = { "tox_comms/client/page_html/" }

function Page:repl(state) return {} end

local rpc_js = require "tox_comms.client.page_html.rpc_js"
Page.rpc_js = {}
for _, name in ipairs{"tox_addrs"} do Page.rpc_js[name] = rpc_js[name] end

return Page
