
default: makeit tox_api.lua events/api.lua

makeit:
	cd events; make

tox_api.h: /usr/include/tox/tox.h
	gcc -E /usr/include/tox/tox.h  |grep -v '# ' > tox_api.h

tox_api.lua: tox_api.h mk_tox_api.sh Makefile
	sh mk_tox_api.sh tox_api.lua tox_api.h

events/api.lua:  events/ToxEvents.h mk_tox_api.sh
	sh mk_tox_api.sh events/api.lua events/ToxEvents.h
