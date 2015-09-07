--  Copyright (C) 07-09-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local string_split = require "tox_comms.util.string_split"

local access = require("tox_comms.Cmd.Access"):new()

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

function Cmd.cmds:get(var)
   local val, allow = access:get(self, string_split(var, "."), self.gettable)
   if allow then
      return access:str(val, "..", allow)
   else
      return "access denied"
   end
end

function Cmd.cmds:set(var, to_str)
   return access:set(self, string_split(var, "."), to_str, self.settable)
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
   local name, rest = string.match(msg, "^[%s]*([%w_]+)[%s]*(.*)")
   local perm = self.permissions.cmds[name]
   if not perm then
      self:msg(string.format("X> No permission to run that command (%q:%s)", name, perm))
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
