PROJECT = mazurka_hyperjson

# Dependencies

PKG_FILE_URL = https://gist.github.com/camshaft/815c139ad3c1ccf13bad/raw/packages.tsv

DEPS = jsx fast_key

dep_fast_key = pkg://fast_key master
dep_jsx = pkg://jsx master

include erlang.mk

# noop
test: all eunit

eunit:
	@rebar eunit

.PHONY: eunit
