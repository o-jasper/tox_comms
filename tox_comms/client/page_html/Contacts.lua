local Page = {}
for k,v in pairs(require "tox_comms.client.page_html.BasePage") do Page[k] = v end
Page.__index = Page

Page.name = "contacts"

function Page:repl(state)
   local fa = string.match(state.rest_path or ">_<", "([%x]+)/?") or self.edge_toxes[1]:addr()
   return { fa = fa }
end

local rpc_js = require "tox_comms.client.page_html.rpc_js"
Page.rpc_js = {}
for _, name in ipairs{"contacts_more"} do Page.rpc_js[name] = rpc_js[name] end

return Page
