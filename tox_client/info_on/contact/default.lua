local This = {}
for k,v in pairs(require "tox_client.info_on.contact.basic") do This[k] = v end
This.__index = This

This.name = "contact/default"

local fancy_hex = require("page_html.util.text.hex").fancy_hex

function This:repl(state)
   if not self._repl then
      self._repl = {
         fa = self.fa, ta = self.ta, contact_name = self.contact_name,
         f_addr = function(addr_mem, front_cnt, aft_cnt)
            local addr = self._repl[string.match(addr_mem, "[%w_]+")]
            return fancy_hex(addr, front_cnt, aft_cnt)
         end,
         f_online = function() return self.claims.online and "{%online_indictator}"
            or "{%offline_indicator}" end,
         offline_indicator = [[<span class="offline">offline</span>]],
         online_indicator  = [[<span class="online">online</span>]],
      }
      self._repl = setmetatable(self._repl, {__index = self.claims})
   end
   return self._repl
end

return This
