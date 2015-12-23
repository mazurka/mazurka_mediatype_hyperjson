Nonterminals

root view object array comprehension conditional property properties assignment expression
expressions literal variable sideeffect call funcall hash path dotpath.

Terminals

string symbol integer float boolean null 'each' 'in' '{' '}' '[' ']' ',' ':' '->' '=' '<' '<=' '>' '>=' '=='
'!=' '!' '&&' '||' '?' '(' ')' '.' '#' '/' '+' '@' '$' '%'.

Rootsymbol root.

Right 100 '=' ':' '?'.
Nonassoc 200 '==' '!=' '<' '>'.
Left 300 '+'.
Left 400 '||'.
Left 500 '&&'.
Unary 600 '!'.
Left 700 '.'.

root -> view : maybe_set_href('$1').

view -> expression : ['$1'].
view -> assignment view : ['$1' | '$2'].
view -> expression view : ['$1' | '$2'].

assignment -> symbol '=' expression : assign('$1', '$3').

expressions -> expression : ['$1'].
expressions -> expression expressions : ['$1' | '$2'].
expressions -> expression ',' expressions : ['$1' | '$3'].

expression -> '!' expression : cond_('$2', [false, true], '$1').
expression -> expression dotpath : dotpath('$1', '$2').
expression -> expression '+' expression : bif(add, ['$1', '$3'], '$2').
expression -> expression '||' expression : cond_('$1', ['$1', '$3'], '$2').
expression -> expression '&&' expression : cond_('$1', ['$3', false], '$2').
expression -> expression '==' expression : bif(equals, ['$1', '$3'], '$2').
expression -> expression '!=' expression : bif(notequals, ['$1', '$3'], '$2').
expression -> expression '<' expression : bif(lt, ['$1', '$3'], '$2').
expression -> expression '<=' expression : bif(lte, ['$1', '$3'], '$2').
expression -> expression '>' expression : bif(gt, ['$1', '$3'], '$2').
expression -> expression '>=' expression : bif(gte, ['$1', '$3'], '$2').
expression -> conditional : '$1'.
expression -> object : '$1'.
expression -> array : '$1'.
expression -> comprehension : '$1'.
expression -> literal : '$1'.
expression -> variable : '$1'.
expression -> call : '$1'.
expression -> sideeffect : '$1'.
expression -> hash : bif(append_hash, [#{<<"href">> => <<>>}, '$1']).

object -> '{' '}' : #{}.
object -> '{' properties '}' : format_properties('$2').

array -> '[' ']' : [].
array -> '[' expressions ']' : '$2'.

conditional -> expression '?' expression : cond_('$1', ['$3'], '$2').
conditional -> expression '?' symbol ':' expression : cond_('$1', [var('$3'), '$5'], '$2').
conditional -> expression '?' expression ':' expression : cond_('$1', ['$3', '$5'], '$2').

comprehension -> '[' each symbol in expression '->' expression ']' : comprehension(nil, assign('$3', nil), '$5', '$7', list, '$2').
comprehension -> '{' each symbol in expression '->' property '}' : comprehension(nil, assign('$3', nil), '$5', '$7', map, '$2').
comprehension -> '[' each symbol symbol in expression '->' expression ']' : comprehension(assign('$4', nil), assign('$3', nil), '$6', '$8', list, '$2').
comprehension -> '{' each symbol symbol in expression '->' property '}' : comprehension(assign('$4', nil), assign('$3', nil), '$6', '$8', map, '$2').
comprehension -> '[' each symbol ',' symbol in expression '->' expression ']' : comprehension(assign('$5', nil), assign('$3', nil), '$7', '$9', list, '$2').
comprehension -> '{' each symbol ',' symbol in expression '->' property '}' : comprehension(assign('$5', nil), assign('$3', nil), '$7', '$9', map, '$2').

properties -> property : ['$1'].
properties -> property ',' properties : ['$1' | '$3'].
properties -> property properties : ['$1' | '$2'].

property -> literal ':' expression : {literal('$1'), '$3'}.
property -> symbol ':' expression : {literal('$1'), '$3'}.
property -> '(' expression ')' ':' expression : {'$2', '$5'}.

literal -> string : literal('$1').
literal -> integer : literal('$1').
literal -> float : literal('$1').
literal -> boolean : literal('$1').
literal -> null : literal({null, line('$1'), nil}).

variable -> symbol : var('$1').
variable -> symbol '/' symbol : nsvar('$1', '$3').
variable -> '$' symbol : prop('$2').

call -> funcall : '$1'.
call -> funcall hash : bif(append_hash, ['$1', '$2']).
%% TODO add metadata
%% call -> funcall '^' object :

sideeffect -> symbol ':' symbol '!' '(' ')' : call('$1', '$3', [], #{"throw" => true}, '$1').
sideeffect -> symbol ':' symbol '!' '(' expressions ')' : call('$1', '$3', '$6', #{"throw" => true}, '$1').

funcall -> symbol '(' ')' : call('__global', '$1', [], #{}, '$1').
funcall -> symbol '(' expressions ')' : call('__global', '$1', '$3', #{}, '$1').
funcall -> symbol ':' symbol '(' ')' : call('$1', '$3', [], #{}, '$1').
funcall -> symbol ':' symbol '(' expressions ')' : call('$1', '$3', '$5', #{}, '$1').
funcall -> '%' symbol object : partial(local, '$2', '$3', '$1').
funcall -> '%' symbol ':' symbol object : partial('$2', '$4', '$5', '$1').
funcall -> '@' symbol '(' ')' : call('__internal', 'resolve-link', [to_atom('$2'), []], #{}, '$1').
funcall -> '@' symbol '(' expressions ')' : call('__internal', 'resolve-link', [to_atom('$2'), '$4'], #{}, '$1').

hash -> '#' path : '$2'.

path -> '/' symbol : [literal('$2')].
path -> '/' '(' expression ')' : ['$3'].
path -> '/' symbol path : [literal('$2') | '$3'].
path -> '/' '(' expression ')' path : ['$3' | '$5'].

dotpath -> '.' symbol : [literal('$2')].
dotpath -> '.' '(' expression ')' : ['$3'].
dotpath -> '.' symbol dotpath : [literal('$2') | '$3'].
dotpath -> '.' '(' expression ')' dotpath : ['$3' | '$4'].

Erlang code.

-define(STRUCT(Name, Props), maps:merge(#{'__struct__' => 'Elixir.Module':concat(['Etude', 'Node', Name])}, Props)).

bif(Name, Args) ->
  bif(Name, Args, {nil, 1}).
bif(Name, Args, Expr) ->
  ?STRUCT('Call', #{
    module => 'Elixir.Module':concat(['Mazurka.Mediatype.Parser.Hyperjson.Dispatch']),
    function => to_atom(Name),
    line => line(Expr),
    arguments => Args,
    attrs => #{
      <<"native">> => true
    }
  }).

assign(Name, Expr) ->
  ?STRUCT('Assign', #{
    name => to_atom(Name),
    line => line(Name),
    expression => Expr
  }).

call({_, _, Module}, Fun, Args, Attrs, Line) ->
  call(Module, Fun, Args, Attrs, Line);
call(Module, {_, _, Fun}, Args, Attrs, Line) ->
  call(Module, Fun, Args, Attrs, Line);
call('__global', <<"to_string">>, [Arg], _Attrs, Line) ->
  bif(to_string, [Arg], Line);
call(Module, Fun, Args, Attrs, Line) ->
  ?STRUCT('Call', #{
    module => to_module_hack_atom(Module),
    function => to_atom(Fun),
    line => line(Line),
    arguments => Args,
    attrs => Attrs
  }).

comprehension(Key, Value, Collection, Expr, Type, Line) ->
  ?STRUCT('Comprehension', #{
    collection => Collection,
    key => Key,
    value => Value,
    expression => Expr,
    type => Type,
    line => line(Line)
  }).

cond_(Expr, Arms, Line) ->
  ?STRUCT('Cond', #{
    expression => Expr,
    line => line(Line),
    arms => Arms
  }).

partial(Mod, Fun, Props, Line) ->
  ?STRUCT('Partial', #{
    module => to_module_hack_atom(Mod),
    function => to_atom(Fun),
    props => Props,
    line => line(Line)
  }).

prop(Name) ->
  ?STRUCT('Prop', #{
    name => list_to_binary(atom_to_list(to_atom(Name))),
    line => line(Name)
  }).

var(Var) ->
  ?STRUCT('Var', #{
    name => to_atom(Var),
    line => line(Var)
  }).

nsvar(NS, Var) ->
  call('__internal', resolve, [literal(NS), literal(Var)], #{}, NS).

literal({_, _, Val}) ->
  Val;
literal(Val) ->
  Val.

maybe_set_href(Exprs) ->
  case lists:reverse(Exprs) of
    [#{'__struct__' := _} | _] ->
      Exprs;
    [Last | Rest] when is_map(Last) ->
      Href = call('__internal', resolve, [<<"rels">>, <<"self">>], #{}, 1),
      Last2 = maps:put(<<"href">>, Href, Last),
      lists:reverse([Last2 | Rest]);
    _ ->
      Exprs
  end.

dotpath(A, []) ->
  A;
dotpath(Parent, [Key|Rest]) when is_binary(Key) ->
  Call = bif(get, [Parent, Key, to_atom(Key)]),
  dotpath(Call, Rest);
dotpath(Parent, [Key|Rest]) ->
  Call = bif(get, [Parent, Key]),
  dotpath(Call, Rest).

format_properties(List) ->
  maps:from_list(List).

to_atom(Atom) when is_atom(Atom) ->
  Atom;
to_atom(Atom) when is_binary(Atom) ->
  list_to_atom(binary_to_list(Atom));
to_atom(Atom) ->
  list_to_atom(binary_to_list(literal(Atom))).

to_module_hack_atom({_, _, Val}) ->
  to_module_hack_atom(Val);
to_module_hack_atom(Atom) when is_atom(Atom) ->
  to_module_hack_atom(atom_to_binary(Atom, latin1));
to_module_hack_atom(<<C,_/binary>> = Name) when C >= $A, C =< $Z ->
  DotedName = binary:replace(Name,<<"_">>,<<".">>,[global]),
  to_atom(<<"Elixir.",DotedName/binary>>);
to_module_hack_atom(Name) ->
  to_atom(Name).

line(Line) when is_integer(Line) ->
  Line;
line(Info) when is_tuple(Info) ->
  element(2, Info);
line(#{line := Line}) ->
  Line;
line(_) ->
  nil.
