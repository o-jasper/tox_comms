local Page = {}
for k,v in pairs(require "tox_client.BasePage") do Page[k] = v end
Page.__index = Page

Page.name = "aliasses"

function Page:repl(state)
   return setmetatable({ name=self.name },
      { __index = require "tox_client.repl_package" })
end

Page.rpc_js = {}

function Page.rpc_js:tox_addrs()
   return function()
      print(self.edge_toxes)
      local ret = {}
      for _, el in ipairs(self.edge_toxes) do
         print(el:addr())
         table.insert(ret, el:addr())
      end
      return ret
   end
end

return Page
