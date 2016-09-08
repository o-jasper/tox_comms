-- Adds savedata, defaulting to particular storage locations.

local Bare = require "Tox.Bare"
local This = Bare:class_derive{ __name = "Tox" }

This.pubkey_name = "default"

function This:init()  -- Note: this makes it only forward from the bare..
   self.dir = self.dir or os.getenv("HOME") .. "/.tox_comms/" .. self.pubkey_name
   if self.savedata_file then  -- Get from savedata if possible.
      if self.savedata_file == true then
         self.savedata_file = self.dir .. "/savedata"
      end
      local fd = io.open(self.savedata_file)
      self.savedata = fd:read("*a")
      fd:close()
   end
   self:load_friend_list()
   Bare.init(self)
end

local function proper_io_lines(file)
   local fd = io.open(file)
   if fd then
      fd:close()
      return io.lines(file)
   else
      return ipairs{}
   end
end

function This:load_friend_list(file)
   if self.friend_list_file == true then
      self.friend_list_file = self.dir .. "/friend_list.txt"
   end

   for addr in proper_io_lines(file or self.friend_list_file) do
      self:ensure_fid(addr)
   end
end

function Bare:save(savedata_file, friend_list_file)
   -- Savedata.
   self:write_savedata(savedata_file or self.savedata_file)

   -- Friend list.
   local fd = io.open(friend_list_file, self.friend_list_file, "w")
   for addr, _ in pairs(self.addr2fid) do
      fd:write(addr .. "\n")
   end
   fd:close()
end

return This
