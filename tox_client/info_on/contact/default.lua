local This = {}
for k,v in pairs(require "tox_client.info_on.contact.basic") do This[k] = v end
This.__index = This

This.name = "contact/default"

function This:repl(state)
   if not self._repl then
      self._repl = {
         fa = self.fa, ta = self.ta, contact_name = self.contact_name,
      }
      local function index(_, key)
         return self.claims[key] or state.repl[key]
      end
      self._repl = setmetatable(self._repl, {__index = index})
   end
   return self._repl
end

return This
