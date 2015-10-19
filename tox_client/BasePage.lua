local Page = {}

function Page:new(new)
   new = setmetatable(new or {}, self)
   new:init()
   return new
end

function Page:init(new)
   self.edgechat = self.edgechat
   self.edge_toxes = self.edge_toxes or {}
end

Page.where = { "tox_client/" }

local Assets = require "page_html.Assets"
function Page:repl_pattern(state)  -- Try find it directly.
   return Assets:new{ where = state.where or self.where }:load(state.rest_path)
end

return Page
