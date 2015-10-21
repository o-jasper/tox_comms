local list = { "Base", "OneAddr", "ContactList", "ContactAdd", "AliasClaim"}

local Page = require("tox_client.combine")(list, "tox_client.functionality.")

Page.name = "contacts"

return Page
