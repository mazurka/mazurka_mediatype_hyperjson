-module(mazurka_mediatype_hyperjson).

-export([parse/2]).
-export([parse_file/2]).
-export([serialize/1]).
-ifdef(TEST).
-export([to_string/1]).
-endif.

parse(Src, Opts) ->
  case mazurka_mediatype_hyperjson_lexer:string(to_string(Src), Opts) of
    {ok, Tokens, _} ->
      mazurka_mediatype_hyperjson_parser:parse(Tokens);
    Error ->
      Error
  end.

parse_file(File, Opts) ->
  case read_file(File) of
    {ok, Src} ->
      parse(Src, Opts);
    Error ->
      Error
  end.

read_file(File) ->
  case file:read_file(File) of
    {ok, Bin} ->
      {ok, to_string(Bin)};
     Error ->
       Error
  end.

serialize(Obj) ->
  'Elixir.Poison':'encode_to_iodata!'(Obj).

to_string(Bin) when is_list(Bin) ->
  Bin;
to_string(Bin) when is_binary(Bin) ->
  case unicode:characters_to_list(Bin) of
    L when is_list(L) ->
      L;
    _ ->
      binary_to_list(Bin)
  end.
