-module(hypermark_hyperjson_serializer).

-export([serialize/1]).
-export([serialize/2]).

serialize(Res) ->
  serialize(Res, []).

serialize(Res, Opts) ->
  HREF = fast_key:get(href, Res, undefined),
  State = fast_key:get(state, Res, []),
  Transitions = fast_key:get(transitions, Res, []),

  NewState = [
    {href, HREF}|
    format_transitions(Transitions, State)
  ],
  {ok, jsx:encode(NewState, [{pre_encode, fun filter_undefined/1}|Opts])}.

format_transitions([], Acc) ->
  Acc;
format_transitions([{Name, Link}|Transitions], Acc) ->
  format_transitions(Transitions, [{Name, [
    {href, Link}
  ]}|Acc]);
format_transitions([{Name, Action, Method, []}|Transitions], Acc) ->
  format_transitions(Transitions, [{Name, [
    {action, Action},
    {method, Method}
  ]}|Acc]);
format_transitions([{Name, Action, Method, Input}|Transitions], Acc) ->
  format_transitions(Transitions, [{Name, [
    {action, Action},
    {method, Method},
    {input, Input}
  ]}|Acc]).

filter_undefined(undefined) ->
  null;
filter_undefined(T) ->
  T.
