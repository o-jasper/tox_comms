local string_split = require "tox_comms.util.string_split"

local This = {}
This.__index = This

function This:new(new)
   new = setmetatable(new or {}, self)
   self:init()
   return new
end

This.new_from_table= This.new

This.cmd_help = {
   {"get",
    "[variable]         -- Gets a variable, if permissable.\n" ..
       "  `.get gettable`    to see what is accessible.\n" ..
       "  `.get permissions` to see what commands are permissible."},
   {"set",
    "[variable] [value] -- Sets a variable, if permissable.\n  `.get settable` to see what."},
   {"help",       "[cmd]              -- Shows help info."},
   {"friendadd",  "[addr]             -- Add another as friend.`"},
   {"speakto",    "[addr] [..text..]  -- Echo what is next into the indicated friend.`"},
   {"about",      "                   -- Some info on me."},
   {"mail",       "[..text...]        -- Send \"mail\", only for comments about the bot."},
   {"addr",       "                   -- Tell the address of the bot."},
   {"stop",       "                   -- Stops the bot."},
}

function This:init()
   --assert(getmetatable(self).__index)--.permissions)
   self.permissions = self.permissions or {
      any_cmds = true,
      cmds = { get=true, set=true, help=true,
               friendadd=false,
               speakto=false, about=true,
               mail=true, addr=true,
               friend_list = false,
      }
   }
   self.settable = {}
   self.gettable = { permissions = true, settable=true, gettable=true, cmd_help=true }
end

This.cmds = {}
function This.cmds:help(on)
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

function This:cmd_get_val(str)
   local val, allow = self, self.gettable
   for _ ,el in ipairs(string_split(str, "[%s]+", false)) do
      allow = (allow == true) or allow[el]
      if not allow then return end
      val = val[el]
   end
   return val, allow
end

function This.cmds:get(str)
   local val, allow = self:cmd_get_val(str or "")
   if allow then
      return table.concat(liststr_val(nil, val, "-> ..", allow), "\n")
   else
      return "access denied"
   end
end

function This.cmds:set(str, val_str)
   local sl = string_split(str)
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

function This.cmds:friendadd(addr, msg)
   local perm = self.permissions.friendadd
   if perm then
      local add_msg = "I am a bot, was asked to add you."
      if perm == "name_origin" then
         add_msg = add_msg .. " From: " .. self.friend:addr()
      else
         return "Dont recognize " .. tostring(perm) .. " as permission."
      end
      self.self.tox:friend_add(addr,  add_msg, #add_msg)
      return "added"
   else
      return "you do not have the permissions for that."
   end
end

function This.cmds:speakto(addr, ...)
   local perm = self.permissions.speakto
   if perm then
      local add_msg = "I am a bot, was asked to add you."
      if perm == "name_friend" then
         add_msg = add_msg .. " From: " .. self.friend:addr()
      elseif type(perm) == "table" then
         return "this sort of permission not yet implemented.(thus denied)"
      end
      local friend = self.bot.friends[addr]
      if friend then
         friend:send_message(table.concat({...}, " "))
         return "msg sent"
      else
         return "have to add the friend first"
      end   
      --self.self.tox:friend_add(addr,  add_msg, #add_msg)
   else
      return "you do not have the permissions for that."
   end
end

function This.cmds:about()
   local ret = [[Basic bot with permissions/accessing/cmds template.
https://github.com/o-jasper/tox_comms]]
   if self.permissions.cmds.addr then
      return ret .. "\n(this instance:" .. self.bot.tox:addr() .. ")"
   end 
   return ret
end

function This.cmds:addr()
   return self.bot.tox:addr()
end

function This.cmds:mail()
   return "Not yet implemented"
end
function This.cmds:stop()
   return "Not yet implemented"
end

function This.cmds:friends_list()
   local ret = {}
   for addr, friend in pairs(self.bot.friends) do
      table.insert(ret, string.format("%s; %s", friend.assured_name or friend.name, addr))
   end
   return table.concat(ret, "\n")
end

function This:msg(text)
   self.friend:send_message(text)
end

function This:on_cmd_msg(msg)
   local args = string_split(msg)
   local name = args[1]
   table.remove(args, 1)
   if self.cmds[name] then
      if self.permissions.cmds[name] == true then
         self:msg("-> " ..tostring(self.cmds[name](self, unpack(args)) or nil))
      else
         self:msg("No permission to run that command")
      end
      return true
   end
end

function This:on_message(kind, msg)
   if string.sub(msg, 1, 1) == "." then
      if self.permissions.any_cmds then
         return self:on_cmd_msg(string.sub(msg, 2))
      end
   end
end

function This:on_connection_status(status)
   print("status", status)
end

This.say_hello = "Hello! I am a bot!"
This.max_namelen = 100
function This:on_status_message(msg)
   if self.say_hello and not self.said_hello then
      self.said_hello = true
      local perms = self.permissions
      self:msg(self.say_hello ..
               (perms.any_cmds and perms.cmds.help and " Use .help for options." or ""))
   end
   print("status_msg", msg)
   self.status_msg = string.sub(msg, This.max_namelen)
end
function This:on_name(name)
   self.name = string.sub(name, This.max_namelen)
end

function This:save()
   -- Nothing, defaultly.
end

return This
