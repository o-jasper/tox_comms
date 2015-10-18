local This = {}
for k,v in pairs(require "page_html.serve.Suggest") do This[k] = v end
This.__index = This

This.name = "contact/basic"

function This:init()
   self.contact_name = self.name
   self.name = nil  -- Need this one cleared.
end

function This:priority()
   return 0
end

function This:repl()
   if not self._repl then
      self._repl = { fa = self.fa, ta = self.ta, name = self.contact_name }
      -- TODO want to display some history too..
      self._repl = setmetatable(self._repl, {__index = self.claims})
   end
   return self._repl
end

return This
