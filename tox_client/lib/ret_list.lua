local function html_list(list, state)
   local ret = {}
   for i, info in ipairs(list) do
      assert(info.output, "one of the info object did not have a :html method")
      table.insert(ret, info:output(state))
   end
   return ret
end

return function(list, state)
   return {
      cnt       = #list,
      html_list = state.html_list and html_list(list, state),
      list      = state.list and list,
   }
end
