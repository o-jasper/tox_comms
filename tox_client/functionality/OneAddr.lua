local Page = { __name="OneAddr" }

function Page:repl(state)
   local fa = string.match(state.rest_path or ">_<", "^([%x]+)/?$") 
      or self.edge_toxes[1]:addr()
   return setmetatable({ name=self.name, fa = fa },
      {__index = require "tox_client.repl_package" } )
end

return Page
