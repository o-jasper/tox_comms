local repl = {
   connection_off     = [[<span style="color:red">off</span>]],
   connection_unknown = [[<span style="color:red">unknown</span>]],
   connection_udp     = [[<span style="color:#0F3;text-weight:bold">udp</span>]],
   connection_tcp     = [[<span style="color:green;text-weight:bold">tcp</span>]],
}

-- introduce source
function repl:js(x)
   return string.format([[<script type="text/javascript" src="/%s/js/%s.js"></script>]],
      self.name, string.sub(x, 2))
end
function repl:css(x)
   return string.format([[<style>{%%css/%s.css}</style>]], string.sub(x, 2))
   -- Persistent in not working
   --      return string.format([[<link rel="stylesheet" href="/%s/css/%s.css">]],
--         self.name, string.sub(x, 2))
end

-- Show online state.
function repl:f_online()
   return "{%connection_" .. 
      (({[0]="off", [1]="udp", [2]="tcp"})[tonumber(self.connection_status) or 0] or 
            "uk" .. tostring(self.connection_status)) .. "}"
end

-- Nicer hexadeximal, highlighting front and back.
local fancy_hex = require("page_html.util.text.hex").fancy_hex

function repl:f_addr(addr_mem, front_cnt, aft_cnt)
   local addr = self[string.match(addr_mem, "[%w_]+")]
   return fancy_hex(addr, front_cnt, aft_cnt)
end

return repl
