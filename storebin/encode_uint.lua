local char, floor = string.char, math.floor

return function(fd, x)
   while x >= 128 do
      fd:write(char(x%128 + 128))
      x = floor(x/128)
   end
   fd:write(char(x))
end
