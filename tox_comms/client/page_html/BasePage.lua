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

Page.where = { "tox_comms/client/page_html/" }

return Page
