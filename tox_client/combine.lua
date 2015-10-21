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
   local Page = { rpc_js={}, _repl_list={} }

   for _, el in ipairs(list) do
      if type(el) == "string" then
         el = require((prep or "") .. el)
      end
      if el then
         assert( not el.__index )
         for k,v in pairs(el) do
            if k == "rpc_js" then
               for k2,v2 in pairs(el.rpc_js) do Page.rpc_js[k2] = v2 end
            elseif k == "repl" then
               table.insert(Page._repl_list, v)
            elseif not ({__name=true, repl=true})[k] then
               Page[k] = copy(v)
            end
         end
      end
   end

   Page.repl = function(self, state)
      local cur, cur_repl = {}, {}
      local function index(_, key)
         if cur[key] then return cur[key] end

         for i = 1,#self._repl_list do
            cur_repl[i] = cur_repl[i] or self._repl_list[i](self, state)
            local got = cur_repl[i][key]
            if got then
               cur[key] = got
               return got
            end
         end
      end
      return setmetatable({}, {__index = index})
   end

   Page.__index = Page

   return Page
end
