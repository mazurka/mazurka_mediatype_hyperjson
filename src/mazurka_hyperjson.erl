-module(mazurka_hyperjson).

-export([parse/2]).
-export([parse_file/2]).
-export([serialize/1]).

parse(Src, _Opts) ->
  case mazurka_hyperjson_lexer:string(to_string(Src)) of
    {ok, Tokens, _} ->
      mazurka_hyperjson_parser:parse(Tokens);
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
  jsx:encode(Obj, []).

to_string(Bin) when is_list(Bin) ->
  Bin;
to_string(Bin) when is_binary(Bin) ->
  case unicode:characters_to_list(Bin) of
    L when is_list(L) ->
      L;
    _ ->
      binary_to_list(Bin)
  end.
