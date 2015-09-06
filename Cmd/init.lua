--  Copyright (C) 06-09-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local string_split = require "tox_comms.util.string_split"

local Cmd = {}
Cmd.__index = Cmd

Cmd.cmd_help = {
   {"get",
    "[variable]         -- Gets a variable, if permissable.\n" ..
       "  `.get gettable`    to see what is accessible.\n" ..
       "  `.get permissions` to see what commands are permissible."},
   {"set",
    "[variable] [value] -- Sets a variable, if permissable.\n  `.get settable` to see what."},
   {"help",       "[cmd]              -- Shows help info."},
   {"about",      "                   -- Some info on me."},
}

function Cmd:init()
   --assert(getmetatable(self).__index)--.permissions)
   self.permissions = self.permissions or {
      any_cmds = true,
      cmds = { get=1, set=2, help=1,
               about=0,
      }
   }
   self.settable = self.settable or {}
   self.gettable = self.gettable or
      { permissions = true, settable=true, gettable=true, cmd_help=true }
end

Cmd.cmds = {}

function Cmd.cmds:help(on)
   local ret, access = {}, false
   local function ins(name, str, ...)
      if (not on or on == name) and self.permissions.cmds[name] then
         access = on
         table.insert(ret, string.format(".%s " .. str, name, ...))
      end
   end
   if not on then table.insert(ret, "Commands:(only permitted shown)") end
   for _, el in pairs(self.cmd_help) do ins(unpack(el)) end

   return table.concat(ret, "\n"), access
end

function Cmd:cmd_get_val(var)
   local val, allow = self, self.gettable
   for _ ,el in ipairs(string_split(var, ".")) do
      allow = (allow == true) or allow[el]
      if not allow then return end
      val = val[el]
   end
   return val, allow
end

local function liststr_val(ret, val, pre, allow)
   if not allow then return "<not allowed>" end
   local ret = ret or {}
   if type(val) == "table" then
      local cnt = 0
      for k,v in pairs(val) do
         cnt = cnt + 1
         liststr_val(ret, v, pre .. "." .. k, allow == true or allow[k])
      end
      if cnt == 0 then
         table.insert(ret, pre .. " = {}")
      end
   else
      table.insert(ret, pre .. " = " .. tostring(val))
   end
   return ret
end

Cmd.liststr_val = liststr_val

function Cmd.cmds:get(var)
   local val, allow = self:cmd_get_val(var or "")
   if allow then
      return table.concat(liststr_val(nil, val, "..", allow), "\n")
   else
      return "access denied"
   end
end

function Cmd.cmds:set(var, val_str)
   local sl = string_split(var, ".")
   local val, allow = self, self.settable
   for i, el in ipairs(sl) do
      allow = (allow == true) or allow[el]
      if not allow then
         return string.format("Not allowed; %s, %d", el,i)
      elseif i == #sl then
         if type(allow) ~= "string" then
            return "Not allow endpoint"
         elseif allow == "string" then
            val[el] = val_str
            return "Success"
         elseif allow == "number" then
            local x = tonumber(val_str)
            if x then
               val[el] = x
               return "Success"
            else
               return "Only number allowed here."
            end
         elseif allow == "boolean" then
            if val_str == "true" or val_str == "1" then
               val[el] = true
            elseif val_str == "false" or val_str == "nil" then
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

function Cmd.cmds:about()
   local ret = [[Basic command interface with permissions/accessing/cmds template.
https://github.com/o-jasper/tox_comms]]
   if self.permissions.cmds.addr then
      return ret .. "\n(this instance:" .. self.bot.tox:addr() .. ")"
   end 
   return ret
end

function Cmd:msg(text) print(text) end

function Cmd:on_cmd(msg)
   local name, rest = string.match(msg, "^[%s]*([%w]+)[%s]*(.*)")
   local perm = self.permissions.cmds[name]
   if not perm then
      self:msg("X> No permission to run that command")
   elseif not self.cmds[name] then
      self:msg("X> Have permission, but command not defined.")
   elseif perm == "text" then
      self:msg("-> " .. tostring(self.cmds[name](self, rest) or nil))
   elseif type(perm) == "number" then
      local args = {}
      for _,el in ipairs(string_split(rest)) do
         if el ~= "" then table.insert(args, el) end
      end

      if #args > perm then
         self:msg("c> too many args %d > %d, cut rest off", #args, perm)
      end
      while #args > perm do table.remove(args) end
         self:msg("-> " .. tostring(self.cmds[name](self, unpack(args)) or nil))
   else
      self:msg("X> permission failed on arguments.")
   end
   return true
end

return Cmd
