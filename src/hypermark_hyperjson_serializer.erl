-module(hypermark_hyperjson_serializer).

-export([serialize/1]).
-export([serialize/2]).

serialize(Res) ->
  serialize(Res, []).

serialize(Res, Opts) ->
  Doc = lists:reverse(add_href([], Res, Opts)),

  {ok, jsx:encode(Doc, [{pre_encode, fun filter_undefined/1}|Opts])}.

add_href(Doc, Res, Opts) ->
  case fast_key:get(href, Res, fast_key:get(<<"href">>, Res)) of
    undefined ->
      error(missing_href);
    Href ->
      add_error([{href, Href}|Doc], Res, Opts)
  end.

add_error(Doc, Res, Opts) ->
  Doc2 = case fast_key:get(error, Res) of
    undefined ->
      Doc;
    Error ->
      %% TODO format error
      [{error, Error}|Doc]
  end,
  add_properties(Doc2, Res, Opts).

add_properties(Doc, Res, Opts) ->
  Properties = fast_key:get(properties, Res, []),
  Doc2 = add_property(Doc, Properties, Opts),
  add_links(Doc2, Res, Opts).

add_property(Doc, [], _Opts) ->
  Doc;
add_property(Doc, [{Name, Value}|Properties], _Opts) ->
  add_property([{Name, Value}|Doc], Properties, _Opts).

add_links(Doc, Res, Opts) ->
  Doc2 = add_link(Doc, fast_key:get(links, Res, []), Opts),
  Doc3 = add_link(Doc2, fast_key:get(item_links, Res, []), Opts),
  add_actions(Doc3, Res, Opts).

add_link(Doc, [], _Opts) ->
  Doc;
add_link(Doc, [{Rel, Href}|Links], _Opts) ->
  add_link([{Rel, [{href, Href}]}|Doc], Links, _Opts);
add_link(Doc, [{Rel, Href, Props}|Links], _Opts) ->
  add_link([{Rel, [{href, Href}|Props]}|Doc], Links, _Opts).

add_actions(Doc, Res, Opts) ->
  Actions = fast_key:get(actions, Res, []),
  Doc2 = add_action(Doc, Actions, Opts),
  add_collection(Doc2, Res, Opts).
%% TODO handle undefined method
add_action(Doc, [], _Opts) ->
  Doc;
add_action(Doc, [{Name, Method, Action, []}|Actions], Opts) ->
  add_action([{Name, [
    {method, Method},
    {action, Action}
  ]}|Doc], Actions, Opts);
add_action(Doc, [{Name, Method, Action, Input}|Actions], Opts) ->
  add_action([{Name, [
    {method, Method},
    {action, Action},
    %% TODO format this better
    {input, Input}
  ]}|Doc], Actions, Opts).

add_collection(Doc, Res, _Opts) ->
  case fast_key:get(collection, Res) of
    undefined ->
      Doc;
    Coll ->
      %% TODO format this better
      [{data, Coll}|Doc]
  end.

filter_undefined(undefined) ->
  null;
filter_undefined(T) ->
  T.
