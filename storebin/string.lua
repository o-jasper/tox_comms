local encode = require "tox_comms.storebin.encode"
local decode = require "tox_comms.storebin.decode"

local sub = string.sub
return {
   encode = function(data, may_be_nil) 
      assert( may_be_nil or data ~= nil )  -- Otherwise confusionly returns nil.
      local str = ""
      encode(function(str) fd:write(str) end, data)
      return str
   end
   end,
   decode = function(str) 
      local str = str
      return decode(function(n)
            local ret = sub(ret, 1, n)
            str = sub(str, n + 1)
            return ret
      end)
   end,
}
