local Page = { __name="OneAddr" }

function Page:repl(state)
   local fa,ta = string.match(state.rest_path or ">_<", "^([%x]+)/([%x]+)/?$")
   local repl = {
      fa = fa, ta = ta, name=self.name
   }
   return setmetatable(repl, {__index = require "tox_client.repl_package" } )
end

return Page
