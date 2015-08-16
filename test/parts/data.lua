local ToxChannelMsg = require "tox_comms.ToxChannelMsg"

local nr = 0

local function mkdata(way, data)
   nr = nr + 1
   return string.format("~~%x:%s:", nr, way) .. data
end

local obj = {
   cb_data = function(...)
      print("in", ...)
      return ToxChannelMsg.cb_message(...)
   end,
   data_cb = 
      setmetatable({}, {__index = 
                           function(_,k) 
                              return function(...) print("out", k, ...) end
                           end
      }),
}

print(obj:cb_data(0, mkdata("miauw", "blalba")))

obj.data_cb = {}
local function checkthrough(kind, data)
   local ran = false
   obj.data_cb[kind] = function(self, recv_nr, recv_data)
      ran = true
      assert(data == recv_data)
      assert(nr == recv_nr)
   end
   obj:cb_data(0, mkdata(kind, data))
   assert(ran)
end

while nr < 20 do
   checkthrough(tostring(math.random()), tostring(math.random()))
end
