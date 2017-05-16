default: settings.lua

update_shas:
	date +%s > json_shas ; sha256sum nodes.json >> json_shas

# Get the bootstrappers
nodes.json:
	wget https://nodes.tox.chat/json -O $@

# Settings.
settings.lua: nodes.json
	lua extract_json.lua nodes.json > $@ ; make update_shas
