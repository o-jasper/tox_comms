local Page = { rpc_js={}, __name="ContactList" }

Page.contact_list_info_ons = { require "tox_client.info_on.contact.default" }
Page.contact_1_info_ons = Page.contact_list_info_ons

local ret_list = require "tox_client.lib.ret_list"
local info_on  = require "page_html.info_on"

function Page.rpc_js:contact_html_list(fa, state)
   local list = {}
   for ta, edge in pairs(self.edgechat:ensure_from(fa)) do
      local ret = { fa = fa, ta = ta }
      for k,v in pairs(edge) do ret[k] = v end
      table.insert(list, ret)
   end

   state.repl = require "tox_client.repl_package"
   state.self = self
   local info_list = info_on.list(list, state, self.contact_list_ons)

   state.where = self.where
   return ret_list(info_list, state)
end

function Page.rpc_js:contact_html_list_1(fa, ta, state)
   state.repl = require "tox_client.repl_package"
   state.self = self
   local info_list = info_on.list({ self.edgechat:ensure_edge(fa, ta) },
      state, self.contacts_info_ons)

   state.where = self.where
   return ret_list(info_list, state)
end

return Page
