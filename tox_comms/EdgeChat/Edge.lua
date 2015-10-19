local This = {}

This.__index = This
This.gettime = require("socket").gettime

function This:new(new)
   new = setmetatable(new, self)
   new:init()
   return new
end

--{ name=1024, status_message=1024, connection_status=1024 }
This.allow_claims = setmetatable({}, {__index=function() return 256 end})
This.do_history   = setmetatable({}, {__index=function() return true end})

-- This.allow_claim_type_cnt = 16 TODO
-- This.claim_type_cnt = 0

This.history_age  = 10
This.i = 0

function This:init()
   assert(self.addr)
   self.claims = {}
   self.history = {}
end

--This.hist_cnt = 20
local function remove_til_cnt(list, cnt)
   while cnt and #list > cnt do table.remove(list) end
end

function This:see_claim(i, name, what)
   if type(name) == "string" then
      local a = self.allow_claims[name]
      if a then
         local got = what
         if type(got) == "string" and type(a) == "number" then
            got = string.sub(got, 1, a)
         end
         self.claims[name] = got

         self.request_name = (name == "name")

         if self.do_history[name] then
            local hist, t = self.history[name] or {}, self.gettime()
            self.history[name] = hist
            if self.history_age and hist[2] and hist[2][1] > t - self.history_age then
               -- Anti-flooding measure; just replace if two too close together.
               hist[1] = {t, i, got}
            else
               table.insert(hist, 1, {t, i, got})
               remove_til_cnt(hist, self.hist_cnt)
            end
         end
      end
   end
end
-- Nothing useful to do at this stage.
function This:see_msg(i, kind, message) end
function This:see_friend_request(i, message) end
function This:see_missed(i, fi,ti) end

local function mk_do(name)
   local fun_name = "do_" .. name
   return function(self, ...)
      local doer = self.doer
      if doer then
         self.i = self.i + 1
         return doer[fun_name](doer, self.addr, ...)
      else
         return "No doer"
      end
   end
end

for _, el in ipairs{"claim", "msg", "friend_request", "missed"} do
   This["do_" .. el] = mk_do(el)
end

return This
