local list = { "Base", "TwoAddr", "ContactList", "ChatList", "ChatSend"}

local Page = require("tox_client.combine")(list, "tox_client.functionality.")

Page.name = "chat"

return Page

