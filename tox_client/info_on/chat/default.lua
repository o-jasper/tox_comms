local This = {}
for k,v in pairs(require "tox_client.info_on.chat.basic") do This[k] = v end
This.__index = This

This.name = "chat/default"

function This:repl(state)
   if not self._repl then
      self._repl = {
         state = {},
         fa = self.fa, ta = self.ta, name = self.contact_name,
         kind = self.rest[1], msg = self.rest[2],
      }
      for k,v in pairs(require "tox_client.repl_package") do self._repl[k] = v end
      self._repl = setmetatable(self._repl, {__index = self})
   end
   return self._repl
end

return This
