--  Copyright (C) 06-09-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local access = require("tox_comms.Cmd.Access"):new()
local Cmd = require "tox_comms.Cmd"

local This = {}
for k,v in pairs(Cmd) do This[k] = v end
--  Copyright (C) 06-09-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

This.cmds = {}
for k,v in pairs(Cmd.cmds) do This.cmds[k] = v end

This.cmd_help = {}
local function cmd_help(...) table.insert(This.cmd_help, {...}) end
for _,el in ipairs(Cmd.cmd_help) do cmd_help(unpack(el)) end

This.__index = This

function This:new(new)
   new = setmetatable(new or {}, self)
   new:init()
   return new
end

This.new_from_table= This.new

cmd_help("friendadd",  "[addr]             -- Add another as friend.`")
cmd_help("speakto",    "[addr] [..text..]  -- Echo what is next into the indicated friend.`")
cmd_help("mail",       "[..text...]        -- Send \"mail\", only for comments about the bot.")
cmd_help("addr",       "                   -- Tell the address of the bot.")

cmd_help("leave_note", "[..text...]        -- Leave a note at the bot(setting overwrites)")
cmd_help("stop",       "                   -- Stops the bot.")
cmd_help("save",       "                   -- Make it save everything.")

cmd_help("friend_edit","[friend addr]      -- Indicate which friend to next change permissions of.")
cmd_help("fget",       "[var]              -- Get something about a friend.")
cmd_help("fset",       "[var] [val]        -- Set something about a friend.")

cmd_help("bget",       "[var]              -- Get something about the bot.")
cmd_help("bset",       "[var] [val]        -- Set something about the bot.")

function This:init()
   --assert(getmetatable(self).__index)--.permissions)
   self.permissions = self.permissions or {
      any_cmds = true,
      cmds = { get = 1, set = 2, help = 1,
               friendadd = false,
               speakto = false, about = 0,
               mail = "text", addr = 0,
               friend_list = false,
               note = "text",
               save = false,
               friendperms = false, fget = false, fset = false,
      },
   }

   self.settable = self.ssettable or { note_left=true }
   self.gettable = self.gettable or {
      permissions = true, settable=true, gettable=true, cmd_help=true,
      addr = true, note_left=true, assured_name=true,
   }
end

function This.cmds:friendadd(input)
   local addr = string.match(input, "^[%s]*([%x]+)[%s]+")
   local add_msg = string.match(input, "[%s]+(.*)$")
   add_msg = add_msg or "I am a bot, was asked to add you."
   local perm = self.permissions.friendadd
   if perm then
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

function This.cmds:speakto(input)
   local addr = string.match(input, "^[%s]*([%x]+)[%s]+")
   local msg = string.match(input, "[%s]+(.+)$")

   local perm = self.permissions.speakto
   if perm then
      if msg then
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
      else 
         return "Not sent; what is the message?"
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
function This.cmds:leave_note(text)
   if not text or text == "" then
      return self.note_left and ("Current note is:\n" .. self.note_left) or "No current note"
   else
      self.note_left = text
      return "Made note"
   end
end
function This.cmds:stop()
   self.bot.stop = true
   return "Stopping.. (depends on loop implementation)"
end

function This.cmds:friends_list()
   local ret = {}
   for addr, friend in pairs(self.bot.friends) do
      table.insert(ret, string.format("%s; %s", friend.assured_name or friend.name, addr))
   end
   return table.concat(ret, "\n")
end

function This.cmds:save()
   self.bot:save()
   return "Saved stuff"
end

function This.cmds:friend_edit(addr)
   if not addr then
      self.edit_friend = nil
      return "Need an address of the friend involved."
   elseif self.bot.friends[addr] then
      self.edit_friend = self.bot.friends[addr]
      return string.format("Editing friend %s\n, %s%s",
                           addr, self.assured_name or "NO ASSURED NAME",
                           self.assured_name == self.name and ""
                              or "claimed name " .. self.name)
   else
      self.edit_friend = nil
      return string.format("No friend %s listed",  addr)
   end
end

function This.cmds:fget(var)
   if self.edit_friend_info then
      local friend = self.edit_friend
      if not friend then return "No editable friend specified" end

      local info = self.edit_friend_info[friend.addr] or self.edit_friend_info.default or {}
      local allowance = (info == "same_as_self" and self.gettable) or
         access:least(info.get_more_than_self   or self.gettable,
                      info.get_more_than_friend or friend.gettable,
                      info.gettable)
      local val, allow = access:get(friend, string_split(var, "."), allowance)
      if allow then
         return access:str(val, "..", allow)
      else
         return "Access denied."
      end
   end
   return "Nothing gettable about friends."
end

function This.cmds:fset(var, to_str)
   if self.edit_friend_info then
      local friend = self.edit_friend
      if not friend then return "No editable friend specified" end

      local info = self.edit_friend_info[friend.addr] or {}
      local allowance =
         access:least(info.get_more_than_self   or self.settable,
                      info.get_more_than_friend or friend.settable,
                      info.gettable)

      return friend:set(friend, string_split(var, "."), to_str, allowance)
   end
   return "Nothing settable about friends."
end

-- Set/get things about the bot.
function This.cmds:bget(var)
   if self.b_gettable then
      return access:get(self.bot, string_split(var, "."), self.b_gettable)
   else
      return "Nothing gettable about the bot"
   end
end
function This.cmds:bset(var, to_str)
   if self.b_settable then
      return access:get(self.bot, string_split(var, "."), to_str, self.b_settable)
   else
      return "Nothing settable about the bot"
   end
end

function This:msg(text)
   self.friend:send_message(text)
end

function This:on_message(kind, msg)
   if string.sub(msg, 1, 1) == "." then
      local any = self.permissions.any_cmds
      if any == true then
         return self:on_cmd(string.sub(msg, 2))
      elseif any == "vocal" then
         self:msg("X> No permission to do commands at all.")
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
   self.status_msg = string.sub(msg, self.max_namelen)
end
function This:on_name(name)
   self.name = string.sub(name, self.max_namelen)
end

function This:export_table()
   return {
      name = self.name, assured_name = self.assured_name,
      addr = self.addr, said_hello = self.said_hello,
      note_left = self.note_left,
      gettable = self.gettable, settable = self.settable,
      permissions=self.permissions,
      edit_friend_info = self.edit_friend_info,
   }
end

function This:save()
   local dir = self.bot.dir .. "/friends/" .. self.addr .. "/"
   os.execute("mkdir -p " .. dir)

   assert( self.bot.use_file_encode ~= false,
           "Cannot serialize if you disabled file encoding." )

   local file_encode = self.bot.use_file_encode or require("storebin").file_encode
   assert(file_encode(dir .. "self.state", self:export_table()))
end

return This
