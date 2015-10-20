local Page = {}
for k,v in pairs(require "tox_client.functionality.Base") do Page[k] = v end
Page.__index = Page

Page.name = "chat"

Page.info_ons = { require "tox_client.info_on.chat.basic" }

function Page:repl(state)
   local fa,ta = string.match(state.rest_path or ">_<", "^([%x]+)/([%x]+)/?$")
   return setmetatable({ fa = fa, ta = ta, name=self.name },
      {__index = require "tox_client.repl_package" } )
end

Page.rpc_js = {}

local ret_list = require "tox_client.lib.ret_list"
local info_on  = require "page_html.info_on"

function Page.rpc_js:chat_html_list(fa, ta, state)
   local edge = self.edgechat:ensure_edge(fa, ta)
   local list = edge:list_events_after(state.after_time or 0)

   state.repl = require "tox_client.repl_package"
   state.self = self
   state.fa = fa
   state.ta = ta

   local info_list = info_on.list(list, state, self.info_ons)
   state.where = self.where
   return ret_list(info_list, state)
end

function Page.rpc_js:send_chat(fa, ta, kind, text)
   self.edgechat:ensure_edge(fa, ta):do_msg(nil, kind, text)
end

return Page
