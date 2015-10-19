local This = {}
for k,v in pairs(require "page_html.serve.Suggest") do This[k] = v end
This.__index = This

This.name = "contact/default"

function This:init()
   self.contact_name = rawget(self, "name") or "(noname)"
   self.name = nil  -- Need this one cleared.
end

function This:priority() return 0 end

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
