-module(hyper_test).

-include_lib("eunit/include/eunit.hrl").

-define(WILDCARD(Type), (begin
  {ok, CWD} = file:get_cwd(),
  Folder = case filename:basename(CWD) of
    ".eunit" -> filename:join(CWD, "../test/" ++ Type);
    _ -> filename:join(CWD, "test/" ++ Type)
  end,
  Tests = filelib:wildcard(Folder ++ "/*.hyper"),
  [begin
    Base = filename:basename(Test, ".hyper"),
    {Base, filename:join(Folder, Base)}
  end|| Test <- Tests]
end)).

lexer_test_() ->
  [{Title, fun() -> lex(Test) end} || {Title, Test} <- ?WILDCARD("cases")].

parser_test_() ->
  [{Title, fun() -> parse(Test) end} || {Title, Test} <- ?WILDCARD("cases")].

lex(Test) ->
  {ok, Bin} = file:read_file(Test ++ ".hyper"),
  Src = decode(Bin),
  {ok, Out} = file:consult(Test ++ ".stream"),

  {ok, Tokens, _} = mazurka_mediatype_hyperjson_lexer:string(Src),
  Out =:= Tokens orelse ?debugFmt("~n~n  Actual:~n~n  ~p~n", [Tokens]),
  ?assertEqual(Out, Tokens),
  Tokens.

parse(Test) ->
  {ok, Ast} = mazurka_mediatype_hyperjson:parse_file(Test ++ ".hyper", []),
  {ok, [Out]} = case file:consult(Test ++ ".ast") of
    {error, enoent} ->
      {ok, [#{}]};
    Res ->
      Res
  end,
  Out =:= Ast orelse ?debugFmt("~n~n  Actual:~n~n  ~p~n", [Ast]),
  ?assertEqual(Out, Ast).

decode(Bin) ->
  case unicode:characters_to_list(Bin) of
    L when is_list(L) ->
      L;
    _ ->
      binary_to_list(Bin)
  end.
