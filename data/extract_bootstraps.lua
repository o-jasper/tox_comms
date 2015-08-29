
local file = arg[1] or "settings.ini"
local to_file = arg[2] or "settings.lua"
local fd = io.open(file)

local function write_table(fd, got, indent)
   indent = indent or ""
   for k,v in pairs(got) do
      if type(k) == "number" then
         fd:write(indent .. "[" .. tostring(k) .. "]" .. " = ")
      elseif type(k) == "string" then
         if string.match(k, "[%w]+") then
            fd:write(indent .. k .. " = ")
         else
            fd:write(indent .. "[\"" ..  k .. "\"] = ")
         end
      else
         error("what is.. currently not usable as key." .. tostring(k))
      end
      if type(v) == "table" then
         fd:write("{\n")
         write_table(fd, v, indent .. "  ")
         fd:write(indent .. "},\n")
      elseif type(v) == "string" then
         fd:write("\"" .. tostring(v) .. "\",\n")
      else
         fd:write(tostring(v) .. ",\n")
      end
   end
end

local function top_write_table(to_file, got)
   local fd = type(to_file) == "string" and io.open(to_file, "w") or to_file
   fd:write("return {")
   write_table(fd, got, "  ")
   fd:write("}\n")
   fd:close()
end

if fd then
   local got = {}
   while true do
      local line = fd:read("l")
      if not line then
         print("creating " .. to_file)
         return top_write_table(to_file, got)
      end
      local _, to = string.find(line, [[^ *dhtServerList\[%d]+\[%w]+=]])
      if to then
         local index = tonumber(string.match(line, "[%d]+"))
         local cur = got[index] or {}
         got[index] = cur
         cur[string.sub(string.match(line, [[\[%w]+=]]), 2, -2)] = string.sub(line, to + 1)
      end
   end
else
   print("no file", file)
end
