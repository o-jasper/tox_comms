local encode = require "tox_comms.storebin.encode"
local decode = require "tox_comms.storebin.decode"

return {
   encode = function(file, data, may_be_nil) 
      assert( may_be_nil or data ~= nil )  -- Otherwise confusionly returns nil.
      local fd = io.open(file, "w")
      if fd then
         encode(fd, data)
         fd:close()
      end
   end,
   decode = function(file) 
      local fd = io.open(file)
      if fd then
         local ret = decode(fd)
         fd:close()
         return ret
      end
   end,
}
