-module(hyper_test).

-export([generate/1]).

generate(Mod) ->
  Res = resource(),
  io:format("RESOURCE~n~p~n", [Res]),
  Mod:serialize(Res).

resource() ->
  random:seed(now()),
  href() ++ properties() ++ links() ++ item_links() ++ actions() ++ collection().

href() ->
  [{random([href, <<"href">>]), url()}].

properties() ->
  gen_prop(properties, fun property/0).

property() ->
  {
    random([<<"name">>, name]), random([<<"Cameron">>, <<"Mike">>, <<"Tim">>])
  }.

links() ->
  gen_prop(links, fun link/0).

item_links() ->
  gen_prop(item_links, fun link/0).

link() ->
  {
    random([<<"apps">>, users, <<"friends">>]),
    url()
  }.

actions() ->
  gen_prop(actions, fun action/0).

action() ->
  {
    random([<<"search">>, update, <<"remove">>, create]),
    random([<<"GET">>, <<"POST">>, <<"DELETE">>, <<"PUT">>, undefined]),
    url(),
    gen_list(fun input/0)
  }.

input() ->
  {
    random([<<"name">>, email, birthday]),
    [
      {type, random([<<"text">>, <<"range">>])},
      {value, random([undefined, random:uniform(), random:uniform(1000), <<"value">>])}
    ]
  }.

collection() ->
  random([
    [],
    gen_prop(collection, fun items/0)
  ]).

items() ->
  href() ++ [
    {title, random([<<"item1">>, <<"item2">>, <<"item3">>])}
  ].

url() ->
  random([<<"http://testing.com/123">>, <<"http://other.com/413">>]).

random(List) ->
  lists:nth(random:uniform(length(List)), List).

gen_list(Fun) ->
  case random:uniform(5) of
    1 ->
      [];
    Num ->
      [Fun() || _ <- lists:seq(1, Num)]
  end.

gen_prop(Name, Fun) ->
  case gen_list(Fun) of
    [] ->
      [];
    List ->
      [{Name, List}]
  end.
