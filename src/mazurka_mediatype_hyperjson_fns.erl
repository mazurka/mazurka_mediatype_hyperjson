-module(mazurka_mediatype_hyperjson_fns).

-export(['not'/1]).
-export(['or'/2]).
-export(['and'/2]).
-export([add/2]).
-export([equals/2]).
-export([notequals/2]).
-export([append_hash/2]).
-export([to_map/1]).
-export([get/2]).

'not'(false) -> true;
'not'(undefined) -> true;
'not'(nil) -> true;
'not'(_) -> false.

'or'(false, Value) -> Value;
'or'(undefined, Value) -> Value;
'or'(nil, Value) -> Value;
'or'(Value, _) -> Value.

'and'(false, _) -> false;
'and'(_, false) -> false;
'and'(undefined, _) -> false;
'and'(_, undefined) -> false;
'and'(nil, _) -> false;
'and'(_, nil) -> false;
'and'(_, Value) -> Value.

add(undefined, undefined) -> undefined;
add(undefined, B) -> B;
add(A, undefined) -> A;
add(A, B) when is_map(A) andalso is_map(B) -> maps:merge(A, B);
add(A, B) when (is_integer(A) orelse is_float(A)) andalso 
               (is_integer(B) orelse is_float(B)) -> A + B;
add(A, B) when is_binary(A) andalso is_binary(B) -> <<A/binary, B/binary>>.

equals(A, A) -> true;
equals(_, _) -> false.

notequals(A, A) -> false;
notequals(_, _) -> true.

append_hash(Href, []) ->
  Href;
append_hash(Href, undefined) ->
  Href;
append_hash(Href, nil) ->
  Href;
append_hash(#{<<"href">> := Href} = Obj, Parts) when is_binary(Href) ->
  Obj#{<<"href">> => append_hash(Href, Parts)};
append_hash(Href, Parts) when is_binary(Href) andalso is_list(Parts) ->
  iolist_to_binary([Href, <<"#">>, [[<<"/">>, Part] || Part <- Parts]]).

to_map(undefined) -> undefined;
to_map(List) -> maps:from_list(List).

get(_, undefined) -> undefined;
get(_, nil) -> undefined;
get(Key, Parent) -> 'Elixir.Dict':get(Parent, Key).
