PROJECT = hypermark_hyperjson_serializer

# Dependencies

PKG_FILE_URL = https://gist.github.com/CamShaft/815c139ad3c1ccf13bad/raw/packages.tsv

DEPS = jsx fast_key

dep_fast_key = pkg://fast_key master
dep_jsx = pkg://jsx master

include erlang.mk
