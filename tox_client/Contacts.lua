local list = { "Base", "OneAddr", "ContactList", "ContactAdd" }

local Page = require("tox_client.combine")(list, "tox_client.functionality.")

Page.name = "contacts"

return Page
