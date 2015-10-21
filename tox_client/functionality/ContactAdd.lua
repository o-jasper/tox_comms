local Page = { rpc_js = {}, __name="ContactAdd" }

function Page.rpc_js:add_contact(fa, addr, message)
   self.edgechat:ensure_edge(fa, addr):do_friend_request(message)
end

return Page
