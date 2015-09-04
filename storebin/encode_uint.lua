local char, floor = string.char, math.floor

return function(write, x)
   while x >= 128 do
      write(char(x%128 + 128))
      x = floor(x/128)
   end
   write(char(x))
end
