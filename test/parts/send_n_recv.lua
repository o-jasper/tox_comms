
local ToxChannelMsg = require "tox_comms.ToxChannelMsg"

-- Check creating the message too.
local recv = {
   transfers = {},
   cb_chunk = ToxChannelMsg.cb_chunk,
   check_got_chunks = ToxChannelMsg.check_got_chunks,
   chunks = {},
   data_cb = {},
}

local send = {
   data_nr = 0,
   channel_data = ToxChannelMsg.channel_data,
   chunk_max_len = 32,  -- Purposefully short.
   send_chunk = function(self, data)
      assert(#data <= 32)
      return recv:cb_chunk(data)
   end,
}

local function test(data)
   local ran = false
   recv.data_cb["derp"] = function(self, nr, got_data)
      assert( got_data == data )
      ran = true
   end
   send:channel_data("derp", data)
   assert(ran)
end

test("i am short")  -- Only one chunk.

test("i am very very very longxxx")

-- Something longer..
local str, n = "", math.random(100,200)
while n > 0 do
   str = str .. tostring(math.random()) .. "\n"
   n = n - 1
end
test(str)
