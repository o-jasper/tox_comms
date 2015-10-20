local Page = { rpc_js = {}, __name="ContactAdd" }

function Page.rpc_js:add_contact(fa, addr, message)
   -- It is super-complicated.
   self.edgechat.doers[fa]:add_friend(addr, message)
end

return Page
