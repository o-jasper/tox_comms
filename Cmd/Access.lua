local Access = {}

function Access:new() return self end

-- Leats permission of a series of permissions.
function Access:least(...)
   local allow_list, specific = {}, nil
   for _,allow in ipairs{...} do
      if not allow then  -- Plainly disallowed.
         return false
      elseif type(allow) == "string" then
         if specific then
            if allow ~= specific then  -- Not the same specific thing.
               return false
            end
         else
            specifics = allow
         end
      elseif type(allow) == "table" then
         table.insert(allow_list, allow)
      elseif allow ~= true then
         print("BUG an allow not valid?", allow)
         return false
      end  -- If is true, allowed according to that one.
   end
   
   if #allow_list == 1 then return allow_list[1] end
   if #allow_list == 0 then return true end
   
   local function index(_, key)
      local here = {}
      for _, el in ipairs(allow_list) do table.insert(here, el[key]) end
      return self:least(unpack(here))
   end
   return setmetatable({}, {__index=index})
end

function Access:set(into, var, to_str, allow)
   local val = into
   for i, el in ipairs(var) do
      allow = (allow == true) or allow[el]
      if not allow then
         return string.format("Not allowed; %s, %d", el,i)
      elseif i == #var then
         if type(allow) ~= "string" then
            return "Not allow endpoint"
         elseif allow == "string" then
            val[el] = to_str
            return "Success"
         elseif allow == "number" then
            local x = tonumber(to_str)
            if x then
               val[el] = x
               return "Success"
            else
               return "Only number allowed here."
            end
         elseif allow == "boolean" then
            if to_str == "true" or to_str == "1" then
               val[el] = true
            elseif to_str == "false" or to_str == "nil" then
               val[el] = false
            else
               return "Only boolean allowed here"
            end
            return "Success"
         else
            return "Possibly incorrect allow?"
         end
      end
      val = val[el]
   end
end

function Access:get(from, var, allow)
   local val = from
   for _ ,el in ipairs(var) do
      allow = (allow == true) or type(allow) == "table" and allow[el]
      if not allow then return end
      val = val[el]
   end
   return val, allow
end

function Access:list_str(value, pre, allow, ret)
   local ret = ret or {}
   if not allow then
      table.insert(ret, "<not allowed>")
   elseif type(value) == "table" then
      local cnt = 0
      if type(allow) == "table" or allow == true then
         for k,v in pairs(value) do
            cnt = cnt + 1
            self:list_str(v, pre .. "." .. k, allow == true or allow[k], ret)
         end
         if cnt == 0 then
            table.insert(ret, pre .. " = {}")
         end
      else  -- Doesnt specify going into tables.
         table.insert(ret, "<not allowed>")
      end
   else
      table.insert(ret, pre .. " = " .. tostring(value))
   end
   return ret   
end

function Access:str(value, pre, allow)
   return table.concat(self:list_str(value, pre, allow), "\n")
end

return Access
