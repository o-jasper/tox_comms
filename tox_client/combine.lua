-- TODO kindah want something more wholesome.
--  Basically want them to be separate when desired..

local function copy(x)
   if type(x) == "table" and not x.__index then
      local ret = {}
      for k,v in pairs(x) do ret[k] = copy(v) end
      return ret
   else
      return x
   end
end

return function(list, prep)
   local Page = { rpc_js={} }

   for _, el in ipairs(list) do
      if type(el) == "string" then
         el = require((prep or "") .. el)
      end

      if el then
         assert( not el.__index )
         for k,v in pairs(el) do
            if k == "rpc_js" then
               for k2,v2 in pairs(el.rpc_js) do Page.rpc_js[k2] = v2 end
            elseif k ~= "__name" then
               Page[k] = copy(v)
            end
         end
      end
   end
   Page.__index = Page

   return Page
end
