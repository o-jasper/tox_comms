local Page = {}
for k,v in pairs(require "tox_client.BasePage") do Page[k] = v end
Page.__index = Page

Page.name = "contacts"

Page.info_ons = { require "tox_client.info_on.contact.basic" }

function Page:repl(state)
   local fa = string.match(state.rest_path or ">_<", "([%x]+)/?") or self.edge_toxes[1]:addr()
   return { fa = fa }
end

local rpc_js = require "tox_client.rpc_js"
Page.rpc_js = {}
--for _, name in ipairs{"contacts_more"} do Page.rpc_js[name] = rpc_js[name] end

local ret_list = require "tox_client.lib.ret_list"
local info_on  = require "page_html.info_on"
function Page.rpc_js:contact_html_list()
   return function (fa, state)
      print("_", fa, state.html_list)
      local list = {}
      for ta, edge in pairs(self.edgechat:ensure_from(fa)) do
         local ret = { fa = fa, ta = ta }
         for k,v in pairs(edge) do ret[k] = v end
         table.insert(list, ret)
      end

      state.self = self

      local info_list = info_on.list(list, state, self.info_ons)
      state.where = self.where
      return ret_list(info_list, state)
   end
end

return Page
