local Page = { rpc_js = {}, __name="ContactSet" }

-- Examples "name", "status", "status_message"
function Page.rpc_js:alias_set_claim(fa, name, value)
   self.edgechat:ensure_edge(fa, "all"):do_claim(nil, name, value)
end

function Page:repl()
   local pats = {
      bare = [[<input id={%id}
onkeydown='touch_claim_input(event, fa, "{%name}", {%id}, {%bid});'>]]
   }
   pats.with_button = pats.bare .. [[<button id={%bid} onclick='do_claim(fa, "{%name}", {%id}, {%bid});'>S</button>]]
   
   local function alias_set_claim(self, what)
      local name, patname = string.match(what, "([%w_]+).*([%w_]*)")
      assert(name)
      patname = (not patname or patname == "") and "with_button" or patname
      local repl = {
         name = name,
         id = [["claim_{%name}_input"]],
         bid = [["claim_{%name}_button"]],
      }
      local function sub(pat, repl)
         return string.gsub(pat, "{%%([_.:/%w%%]+)|?([_.,%s:/%w%%]*)}", repl)
      end
      return sub(sub(pats[patname] or pats.with_button, repl), repl)
   end
   return { alias_set_claim = alias_set_claim  }
end

return Page
