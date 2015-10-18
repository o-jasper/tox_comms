local Page = {}
for k,v in pairs(require "tox_client.BasePage") do Page[k] = v end
Page.__index = Page

Page.name = "chat"

Page.info_ons = { require "tox_client.info_on.chat.basic" }

function Page:repl(state)
   local fa,ta = string.match(state.rest_path or ">_<", "([%x]+)/([%x]+)/?")
   return { fa = fa, ta = ta }
end

local rpc_js = require "tox_client.rpc_js"
Page.rpc_js = {}
--for _, name in ipairs{"list_events_all"} do Page.rpc_js[name] = rpc_js[name] end

local ret_list = require "tox_client.lib.ret_list"
local info_on  = require "page_html.info_on"

function Page.rpc_js:chat_html_list()
   return function (fa, ta, state)
      local list = {}
      local edge = self.edgechat:ensure_edge(fa, ta)
      for _, el in ipairs(edge.events) do table.insert(list, el) end

      state.self = self
      state.fa = fa
      state.ta = ta

      local info_list = info_on.list(list, state, self.info_ons)
      state.where = self.where
      return ret_list(info_list, state)
   end
end

return Page
