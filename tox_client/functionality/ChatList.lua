local Page = { rpc_js={}, __name="ChatList" }

Page.chat_info_ons = { require "tox_client.info_on.chat.default" }

local ret_list = require "tox_client.lib.ret_list"
local info_on  = require "page_html.info_on"

function Page.rpc_js:chat_html_list(fa, ta, state)
   local edge = self.edgechat:ensure_edge(fa, ta)
   local list = edge:list_events_after(state.after_time or 0)

   state.repl = require "tox_client.repl_package"
   state.self, state.fa, state.ta = self, fa, ta

   state.time_state = { config = { timemarks = { { "minute", [[<td>{%min}</td>]]} }}}

   local info_list = info_on.list(list, state, self.chat_info_ons)
   state.where = self.where
   return ret_list(info_list, state)
end

return Page
