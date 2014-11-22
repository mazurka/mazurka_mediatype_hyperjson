-module(mazurka_mediatype_hyperjson).

-export([parse/2]).
-export([parse_file/2]).
-export([serialize/1]).
-ifdef(TEST).
-export([to_string/1]).
-endif.

parse(Src, Opts) ->
  case mazurka_mediatype_hyperjson_lexer:string(to_string(Src)) of
    {ok, Tokens, _} ->
      TransformedTokens = transform_tokens(Tokens, [], Opts),
      mazurka_mediatype_hyperjson_parser:parse(TransformedTokens);
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
  jsx:encode(remove_undefined(Obj), []).

remove_undefined(Map) ->
  maps:fold(fun
    (_, undefined, Acc) ->
      Acc;
    (K, V, Acc) when is_map(V) ->
      fast_key:set(K, remove_undefined(V), Acc);
    (K, V, Acc) ->
      fast_key:set(K, V, Acc)
  end, #{}, Map).

to_string(Bin) when is_list(Bin) ->
  Bin;
to_string(Bin) when is_binary(Bin) ->
  case unicode:characters_to_list(Bin) of
    L when is_list(L) ->
      L;
    _ ->
      binary_to_list(Bin)
  end.

transform_tokens(Tokens, Acc, #{prefix := Prefix} = Opts) when is_atom(Prefix) ->
  transform_tokens(Tokens, Acc, Opts#{prefix => list_to_binary(atom_to_list(Prefix))});
transform_tokens([], Acc, _Opts) ->
  lists:reverse(Acc);
transform_tokens([{'@',L1},{symbol,L2,Name}|Rest], Acc, #{prefix := Prefix} = Opts) ->
  transform_tokens(Rest, [{symbol,L2,<<Prefix/binary, Name/binary>>},{'@',L1}|Acc], Opts);
transform_tokens([Other|Rest], Acc, #{prefix := _} = Opts) ->
  transform_tokens(Rest, [Other|Acc], Opts);
transform_tokens(Tokens, _, _) ->
  Tokens.
