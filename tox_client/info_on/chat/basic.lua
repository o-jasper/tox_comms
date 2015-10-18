local This = {}
for k,v in pairs(require "page_html.serve.Suggest") do This[k] = v end
This.__index = This

This.name = "chat/basic"

function This:init()
   self.contact_name = self.name
   self.name = nil  -- Need this one cleared.
end

function This:priority()
   return 0
end

function This:repl(state)
   if not self._repl then
      self._repl = { kind = self.rest[1], msg = self.rest[2], }
      -- TODO want to display some history too..
      for k,v in pairs(self) do self._repl[k] = v end
      self._repl.i = self._repl.i or " "
   end
   return self._repl
end

return This
