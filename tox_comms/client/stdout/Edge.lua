local PrevEdge = require "tox_comms.EdgeChat.Edge"

local This = {}
for k,v in pairs(PrevEdge) do This[k] = v end
This.__index = This

function This:see_claim(...)
   PrevEdge.see_claim(self, ...)
   print(self.addr, "CLAIMS:", ...)
end

function This:see_msg(...)
   print(self.addr, "SAYS:", ...)
end

function This:see_missed(...)
   print(self.addr, "MISSED", ...)
end

function This:see_friend_request(...)
   print(self.addr, "FR", ...)
end

return This
