--  Copyright (C) 22-09-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local access = require("tox_comms.Cmd.Access"):new()

local ToxFriend = require "tox_comms.ToxFriend"

local This = {}

local Cmd = require "tox_comms.Cmd"
for k,v in pairs(Cmd) do This[k] = v end

for k,v in pairs(ToxFriend) do
   This[k] = v
end

This.msg = ToxFriend.msg  -- Just to be clear, otherwise, it will only print them!

This.cmds = {}
for k,v in pairs(Cmd.cmds) do This.cmds[k] = v end

This.__index = This

This.new_from_table = This.new

This.cmd_help = {}
local function cmd_help(...) table.insert(This.cmd_help, {...}) end
for _,el in ipairs(Cmd.cmd_help) do cmd_help(unpack(el)) end

-- Note.. concept of streams?
-- (i.e. make a receiver, put things to output into it, tell it to send stuff places)
cmd_help("friendadd",  "[addr]             -- Add another as friend.`")
cmd_help("speakto",    "[addr] [..text..]  -- Echo what is next into the indicated friend.`")
cmd_help("listento",   "[addr]             -- Listen in on guy.`")
cmd_help("onbehalf",   "[addr] [..text..]  -- Pass message as if from him.`")

cmd_help("mail",       "[..text...]        -- Send \"mail\", only for comments about the bot.")
cmd_help("addr",       "                   -- Tell the address of the bot.")

cmd_help("leave_note", "[..text...]        -- Leave a note at the bot(setting overwrites)")
cmd_help("stop",       "                   -- Stops the bot.")
cmd_help("save",       "                   -- Make it save everything.")

cmd_help("friend_edit","[friend addr]      -- Indicate which friend to next change permissions of.")
cmd_help("fget",       "[var]              -- Get something about a friend.")
cmd_help("fset",       "[var] [val]        -- Set something about a friend.")

This.use_file_decode = require "storebin"

function This:init()
   ToxFriend.init(self)

   local dir = self.dir or self.tox.dir
   local from_file = dir .. "/friends/" .. self:addr() .. "/self.state"
   if self.use_file_encode ~= false then
      local args = self.use_file_decode.file_decode(from_file) or {}
      for k,v in pairs(args) do self[k] = v end
   end

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
               friendperms = false, get = false, set = false,
      },
   }

   self.settable = self.settable or { note_left=true }
   self.gettable = self.gettable or {
      permissions = true, settable=true, gettable=true, cmd_help=true,
      addr = true, note_left=true, assured_name=true,
   }

   self.listeners = {}
end

function This.cmds:friendadd(input)
   local addr = string.match(input, "^[%s]*([%x]+)[%s]*")
   if not addr then return "Failed to parse address" end

   local add_msg = string.match(input, "[%s]+(.*)$")
   add_msg = add_msg or "I am a bot, was asked to add you."
   local perm = self.permissions.friendadd
   if perm then
      if perm == "name_origin" then
         add_msg = add_msg .. " (via bot)From: " .. self.friend:addr()
      elseif perm ~= "bare" then
         return "Dont recognize " .. tostring(perm) .. " as permission."
      end
      print("friend request", addr)
      self.tox:add_friend(addr, add_msg, #add_msg)
      return "added"
   else
      return "you do not have the permissions for that."
   end
end

local function figure_friend(self, addr)
   return self.tox:friend_by_pubkey(string.sub(addr, 1, 64))
end

function This.cmds:speakto(input)
   local addr = string.match(input, "^[%s]*([%x]+)[%s]+")
   if not addr then return "could not distinguish address" end
   local msg = string.match(input, "[%s]+(.+)$")

   local perm = self.permissions.speakto
   if perm then
      if msg then
         if perm == "name_friend" then
            add_msg = add_msg .. " From: " .. self:addr()
         elseif type(perm) == "table" then
            return "this sort of permission not yet implemented.(thus denied)"
         end
         local friend = figure_friend(self, addr)
         if friend then
            friend:msg(msg)
            return "msg sent"
         else
            return "have to add the friend first"
         end
      else 
         return "Not sent; what is the message?"
      end
   else
      return "you do not have the permissions for that."
   end
end

function This.cmds:any_cmds(of_addr, dir)
   local f = figure_friend(self, addr)
   if f then
      f.permissions.any_cmds = (dir == "true")
      return (dir == "true") and "Enabled commands" or "Disabled his commands"
   else
      return "Aint got guy like that."
   end
end

function This.cmds:onbehalf(input)
   local perms = self.permissions
   if perms.onbehalf then
      local addr = string.match(input, "^[%s]*([%x]+)[%s]+")
      if not addr then return "Couldnt figure addr" end
      local msg = string.match(input, "[%s]+(.+)$")
      local f = figure_friend(self, addr)
      if f then
         f:cb_message(0, input)
         return "sent message acted as from that addr."
      else
         return "Couldnt find that friend"
      end
   else
      return "Not permitted"
   end
end

function This.cmds:listento(addr)
   local perms = self.permissions
   if perms.listento then
      local friend = figure_friend(self, addr)
      if friend then   -- Add to listeners.
         if friend.permissions.block_listen then
            friend:msg(self.addr .. "tried to listen in")
            return "couldnt find friend of that address (not really, blocked)"
         else
            friend.listeners[self.addr] = true
            return "listening.."
         end
      else
         for pk in pairs(self.tox.friends) do print("*", pk) end
         print("=", addr)
         return "couldnt find friend of that address (really)"
      end
   else
      if friend then
         friend:msg(self.tox:addr() .. "tried to listen in, did he have the permissions?")
      end
      return "couldnt find friend of that address (not really, lack perms)"
   end
end

function This.cmds:about()
   local ret = [[Basic bot with permissions/accessing/cmds template.
https://github.com/o-jasper/tox_comms]]
   if self.permissions.cmds.addr then
      return ret .. "\n(this instance:" .. self.tox:addr() .. ")"
   end 
   return ret
end

function This.cmds:addr()
   return self.tox:addr()
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
   self.tox.stop = true
   return "Stopping.. (depends on loop implementation)"
end

function This.cmds:friends_list()
   local ret = {}
   for addr, friend in pairs(self.tox.friends) do
      table.insert(ret, string.format("%s; %s", friend.assured_name or friend.name, addr))
   end
   return table.concat(ret, "\n")
end

function This.cmds:save()
   self.tox:save()
   return "Saved stuff"
end

function This.cmds:friend_edit(addr)
   if not addr then
      self.edit_friend = nil
      return "Need an address of the friend involved."
   end
   local f = figure_friend(addr)
   if f then
      self.edit_friend = f
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

function This:cb_message(kind, msg)
   local perms = self.permissions
   if string.sub(msg, 1, 1) == "." then
      local any = perms.any_cmds
      if any == true then
         return self:on_cmd(string.sub(msg, 2))
      elseif any == "vocal" then
         self:msg("X> No permission to do commands at all.")
      end
   end

   if not perms.block_listen then
      for addr in pairs(self.listeners) do
         self.tox.friends[addr]:msg(self.name .. ": " .. msg)
      end
   end
end

function This:cb_connection_status(status)
   print("status", status)
end

This.say_hello = "Hello! I am a bot!"
This.max_namelen = 100
function This:cb_status_message(msg)
   if self.say_hello and not self.said_hello then
      self.said_hello = true
      local perms = self.permissions
      self:msg(self.say_hello ..
               (perms.any_cmds and perms.cmds.help and " Use .help for options." or ""))
   end
   print("status_msg", msg)
   self.status_msg = string.sub(msg, 1, self.max_namelen)
end
function This:cb_name(name)
   self.name = string.sub(name, 1, self.max_namelen)
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
   local dir = self.tox.dir .. "/friends/" .. self.addr .. "/"
   os.execute("mkdir -p " .. dir)

   assert( self.tox.use_file_encode ~= false,
           "Cannot serialize if you disabled file encoding." )

   local file_encode = self.tox.use_file_encode or require("storebin").file_encode
   assert(file_encode(dir .. "self.state", self:export_table()))
end

return This
