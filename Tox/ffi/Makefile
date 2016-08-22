
default: tox_api.lua

tox_api.h: /usr/include/tox/tox.h
	gcc -E /usr/include/tox/tox.h  |grep -v '# ' > tox_api.h

tox_api.lua: tox_api.h mk_tox_api.sh Makefile
	sh mk_tox_api.sh
