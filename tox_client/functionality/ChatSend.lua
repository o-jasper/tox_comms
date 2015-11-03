local Page = { rpc_js = {}, __name="ChatSend" }

function Page.rpc_js:send_chat(fa, ta, kind, text)
   self.edgechat:ensure_edge(fa, ta):do_msg(nil, kind, text)
end

return Page
