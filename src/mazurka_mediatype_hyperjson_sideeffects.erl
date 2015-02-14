-module(mazurka_mediatype_hyperjson_sideeffects).

-export([transform/2]).

transform(Ast, _) ->
  {ok, Ast2} = find_sideeffects(Ast, [], []),
  {ok, Ast2}.

find_sideeffects([], Acc, Vars) ->
  {ok, wrap_root(Acc, Vars)};
find_sideeffects([#{force := true, line := Line} = Call | Rest], Acc, Vars) ->
  Var = gen_name(Call),
  Child = #{
    type => assign,
    line => Line,
    value => Var,
    children => [
      Call
    ]
  },
  find_sideeffects(Rest, [Child | Acc], [#{type => variable, line => Line, value => Var} | Vars]);
find_sideeffects([Other | Rest], Acc, Vars) ->
  find_sideeffects(Rest, [Other | Acc], Vars).

gen_name(Call = #{value := {Mod, Fun}}) ->
  <<(to_bin(Mod))/binary, ":", (to_bin(Fun))/binary,
    "#",
    (integer_to_binary(erlang:phash2(Call)))/binary>>.

to_bin(Atom) ->
  list_to_binary(atom_to_list(Atom)).

wrap_root(Acc, []) ->
  lists:reverse(Acc);
wrap_root([Root | Rest], Vars) ->
  lists:reverse([
    #{
      type => call,
      value => {erlang, hd},
      native => true,
      children => [
        #{
          type => list,
          children => [Root | Vars]
        }
      ]
    }
  | Rest]).
