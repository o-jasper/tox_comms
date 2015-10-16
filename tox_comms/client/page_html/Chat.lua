local Page = {}
for k,v in pairs(require "tox_comms.client.page_html.BasePage") do Page[k] = v end
Page.__index = Page

Page.name = "chat"

function Page:repl(state)
   local fa,ta = string.match(state.rest_path or ">_<", "([%x]+)/([%x]+)/?")
   return { fa = fa, ta = ta }
end

local rpc_js = require "tox_comms.client.page_html.rpc_js"
Page.rpc_js = {}
for _, name in ipairs{"list_events_all"} do Page.rpc_js[name] = rpc_js[name] end

return Page
