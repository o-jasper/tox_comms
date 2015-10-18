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

function Page:src_js()
   return function(x)
      return string.format([[<script src="/%s/js/%s.js"></script>]],
         self.name, string.sub(x, 2))
   end
end
function Page:src_css()
   return function(x)
      return string.format([[<style src="/%s/css/%s.css"></style>]],
         self.name, string.sub(x, 2))
   end
end

return Page
