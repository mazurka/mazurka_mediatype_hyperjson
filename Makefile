PROJECT = mazurka_mediatype_hyperjson

# Dependencies

PKG_FILE_URL = https://gist.github.com/camshaft/815c139ad3c1ccf13bad/raw/packages.tsv

DEPS = json_stringify fast_key

dep_fast_key = pkg://fast_key master
dep_json_stringify = https://github.com/camshaft/json_stringify.git

include erlang.mk

# noop
test: all eunit

eunit:
	@rebar eunit

.PHONY: eunit
