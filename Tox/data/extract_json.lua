local json = require "json"

local fd = io.open(arg[1] or "nodes.json")
local got = json.decode(fd:read("*a"))
fd:close()

local list = {}
for _,el in ipairs(got.nodes) do
   el.address = el.ipv6 and #el.ipv6>4 and el.ipv6 or el.ipv4
   el.userId = el.userId or el.public_key
   el.name = el.name or el.maintainer
   table.insert(list, el)
end

io.write( "return {\n")
for _, el in ipairs(list) do
   io.write("{\n")
   for k,v in pairs(el) do
      if type(v) ~= "table" then
         io.write(string.format("  %s = %" .. (type(v) == "string" and "q,\n" or "s,\n"), k, v))
      end
   end
   io.write("},\n")
end
io.write("}\n")
