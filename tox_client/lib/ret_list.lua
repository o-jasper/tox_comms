local function html_list(list, state)
   local ret = {}
   for i, info in ipairs(list) do
      assert(info.output, "one of the info object did not have a :html method")
      table.insert(ret, { html = info:output(state) })
   end
   return ret
end

local gettime = require("socket").gettime

return function(list, state)
   return {
      last_time = state.time or gettime(),
      cnt       = #list,
      html_list = state.html_list and html_list(list, state),
      list      = state.list and list,
   }
end
