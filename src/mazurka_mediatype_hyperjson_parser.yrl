Nonterminals

root
view
object
array
comprehension
conditional
property
properties
assignment
expression
expressions
literal
variable
sideeffect
call
funcall
hash
path
dotpath
.

Terminals

string
symbol
integer
float
boolean
'each'
'in'
'{'
'}'
'['
']'
','
':'
'->'
'='
'=='
'!='
'!'
'&&'
'||'
'?'
'('
')'
'.'
'#'
'/'
'+'
'@'
'&'
.

Rootsymbol root.

Right 100 '=' ':' '?'.
Nonassoc 200 '==' '!='.
Left 300 '+'.
Left 400 '||'.
Left 500 '&&'.
Unary 600 '!'.
Left 700 '.'.

root ->
  view :
  maybe_set_href('$1').

view ->
  expression :
  ['$1'].
view ->
  assignment view :
  ['$1' | '$2'].
view ->
  sideeffect view :
  ['$1' | '$2'].

assignment ->
  symbol '=' expression :
  #{
    type => assign,
    line => ?line('$1'),
    value => ?value('$1'),
    children => [
      '$3'
    ]
  }.

expressions ->
  expression :
  ['$1'].
expressions ->
  expression expressions :
  ['$1' | '$2'].
expressions ->
  expression ',' expressions :
  ['$1' | '$3'].

expression ->
  '!' expression :
  #{
    type => call,
    line => ?line('$1'),
    value => {?FNS, 'not'},
    native => true,
    children => [
      '$2'
    ]
  }.
expression ->
  expression dotpath :
  dotpath('$1', '$2').
expression ->
  expression '+' expression :
  #{
    type => call,
    line => ?line('$2'),
    value => {?FNS, add},
    native => true,
    children => [
      '$1',
      '$3'
    ]
  }.
expression ->
  expression '||' expression :
  #{
    type => call,
    line => ?line('$2'),
    value => {?FNS, 'or'},
    native => true,
    children => [
      '$1',
      '$3'
    ]
  }.
expression ->
  expression '&&' expression :
  #{
    type => call,
    line => ?line('$2'),
    value => {?FNS, 'and'},
    native => true,
    children => [
      '$1',
      '$3'
    ]
  }.
expression ->
  expression '==' expression :
  #{
    type => call,
    line => ?line('$2'),
    value => {?FNS, equals},
    native => true,
    children => [
      '$1',
      '$3'
    ]
  }.
expression ->
  expression '!=' expression :
  #{
    type => call,
    line => ?line('$2'),
    value => {?FNS, notequals},
    native => true,
    children => [
      '$1',
      '$3'
    ]
  }.
expression ->
  conditional :
  '$1'.
expression ->
  object :
  '$1'.
expression ->
  array :
  '$1'.
expression ->
  comprehension :
  '$1'.
expression ->
  literal :
  '$1'.
expression ->
  variable :
  '$1'.
expression ->
  call '&' :
  '$1'#{spawn => true}.
expression ->
  call :
  '$1'.
expression ->
  hash :
  #{
    type => call,
    value => {?FNS, append_hash},
    native => true,
    children => [
      #{
        type => map,
        children => [
          #{
            type => tuple,
            children => [
              #{
                type => literal,
                value => <<"href">>
              },
              #{
                type => literal,
                value => <<>>
              }
            ]
          }
        ]
      },
      '$1'
    ]
  }.

object ->
  '{' '}' :
  #{
    type => map,
    line => ?line('$1'),
    children => []
  }.
object ->
  '{' properties '}' :
  #{
    type => map,
    line => ?line('$1'),
    children => format_properties('$2', [])
  }.

array ->
  '[' ']' :
   #{
     type => list,
     line => ?line('$1'),
     children => []
   }.
array ->
  '[' expressions ']' :
  #{
    type => list,
    line => ?line('$1'),
    children => '$2'
  }.

conditional ->
  expression '?' expression :
  #{
    type => 'cond',
    line => ?line('$2'),
    children => [
      '$1',
      '$3'
    ]
  }.
conditional ->
  expression '?' expression ':' expression :
  #{
    type => 'cond',
    line => ?line('$2'),
    children => [
      '$1',
      '$3',
      '$5'
    ]
  }.

comprehension ->
  '[' each symbol in expression '->' expression ']' :
  #{
    type => comprehension,
    line => ?line('$1'),
    children => [
      #{
        type => assign,
        value => ?value('$3'),
        children => [
          '$5'
        ]
      },
      '$7'
    ]
  }.
comprehension ->
  '{' each symbol in expression '->' property '}' :
  #{
    type => call,
    value => {?FNS, to_map},
    native => true,
    children => [
      #{
        type => comprehension,
        line => ?line('$1'),
        children => [
          #{
            type => assign,
            value => ?value('$3'),
            children => [
              '$5'
            ]
          },
          tuple_to_map('$7')
        ]
      }
    ]
  }.

properties ->
  property :
  ['$1'].
properties ->
  property ',' properties :
  ['$1' | '$3'].
properties ->
  property properties :
  ['$1' | '$2'].

property ->
  literal ':' expression :
  {?literal('$1'), '$3'}.
property ->
  symbol ':' expression :
  {?value('$1'), '$3'}.
property ->
  '(' expression ')' ':' expression :
  {'$2', '$5'}.

literal ->
  string :
  to_map('$1', literal).
literal ->
  integer :
  to_map('$1', literal).
literal ->
  float :
  to_map('$1', literal).
literal ->
  boolean :
  to_map('$1', literal).

variable ->
  symbol :
  to_map('$1', variable).
variable ->
  symbol '/' symbol :
  #{
    line => ?line('$1'),
    type => call,
    value => {'__internal', resolve},
    children => [
      to_map('$1', literal),
      to_map('$3', literal)
    ]
  }.

call ->
  funcall :
  '$1'.
call ->
  funcall hash :
  #{
    type => call,
    value => {?FNS, append_hash},
    native => true,
    children => [
      '$1',
      '$2'
    ]
  }.

sideeffect ->
  symbol ':' symbol '!' '(' ')' :
  #{
    type => call,
    force => true,
    line => ?line('$1'),
    value => to_mf('$1', '$3'),
    children => []
  }.
sideeffect ->
  symbol ':' symbol '!' '(' expressions ')' :
  #{
    type => call,
    force => true,
    line => ?line('$1'),
    value => to_mf('$1', '$3'),
    children => '$6'
  }.

funcall ->
  symbol '(' ')' :
  #{
    type => call,
    line => ?line('$1'),
    value => to_mf({symbol, ?line('$1'), <<"__global">>}, '$1'),
    children => []
  }.
funcall ->
  symbol '(' expressions ')' :
  #{
    type => call,
    line => ?line('$1'),
    value => to_mf({symbol, ?line('$1'), <<"__global">>}, '$1'),
    children => '$3'
  }.
funcall ->
  symbol ':' symbol '(' ')' :
  #{
    type => call,
    line => ?line('$1'),
    value => to_mf('$1', '$3'),
    children => []
  }.
funcall ->
  symbol ':' symbol '(' expressions ')' :
  #{
    type => call,
    line => ?line('$1'),
    value => to_mf('$1', '$3'),
    children => '$5'
  }.
funcall ->
  '@' symbol '(' ')' :
  #{
    type => call,
    line => ?line('$1'),
    value => {'__internal', 'resolve-link'},
    children => [
      to_atom_map('$2'),
      #{
        type => list,
        line => ?line('$1'),
        children => []
      }
    ]
  }.
funcall ->
  '@' symbol '(' expressions ')' :
  #{
    type => call,
    line => ?line('$1'),
    value => {'__internal', 'resolve-link'},
    children => [
      to_atom_map('$2'),
      #{
        type => list,
        line => ?line('$1'),
        children => '$4'
      }
    ]
  }.

hash ->
  '#' path :
  #{
    type => list,
    line => ?line('$1'),
    children => '$2'
  }.

path ->
  '/' symbol :
  [to_map('$2', literal)].
path ->
  '/' '(' expression ')' :
  ['$3'].
path ->
  '/' symbol path :
  [to_map('$2', literal) | '$3'].
path ->
  '/' '(' expression ')' path :
  ['$3' | '$5'].

dotpath ->
  '.' symbol :
  [to_map('$2', literal)].
dotpath ->
  '.' '(' expression ')' :
  ['$3'].
dotpath ->
  '.' symbol dotpath :
  [to_map('$2', literal) | '$3'].
dotpath ->
  '.' '(' expression ')' dotpath :
  ['$3' | '$4'].

Erlang code.

-define(FNS, mazurka_mediatype_hyperjson_fns).
-define(line(Tup), element(2, Tup)).
-define(value(Tup), element(3, Tup)).
-define(literal(Lit), maps:get(value, Lit)).

maybe_set_href(Exprs) ->
  case lists:reverse(Exprs) of
    [Last = #{type := map} | Rest] -> set_href(Last, Rest);
    _ -> Exprs
  end.

set_href(#{children := Children, line := Line} = Item, Rest) ->
  Href = #{
    line => Line,
    type => call,
    value => {'__internal', resolve},
    children => [
      to_map({Line, Line, <<"rels">>}, literal),
      to_map({Line, Line, <<"self">>}, literal)
    ]
  },
  Assoc = #{
    type => tuple,
    line => Line,
    children => [
      #{type => literal, value => <<"href">>, line => Line},
      Href
    ]
  },
  Children2 = [Assoc | Children],
  Item2 = maps:put(children, Children2, Item),
  lists:reverse([Item2 | Rest]).

to_map({_, Line, Value}, Type) ->
  #{type => Type, line => Line, value => Value}.

dotpath(A, []) ->
  A;
dotpath(Parent, [Key|Rest]) ->
  dotpath(#{
    type => call,
    native => true,
    value => {?FNS, get},
    children => [
      Key,
      Parent
    ]
  }, Rest).

format_properties([], List) ->
  lists:reverse(List);
format_properties([{Key, Expr}|KVs], List) when is_binary(Key) ->
  Tuple = #{
    type => tuple,
    children => [
      #{type => literal, value => Key},
      Expr
    ]
  },
  format_properties(KVs, [Tuple|List]);
format_properties([{Key, Expr}|KVs], List) ->
  Tuple = #{
    type => tuple,
    children => [
      Key,
      Expr
    ]
  },
  format_properties(KVs, [Tuple|List]).

tuple_to_map(Tuple) ->
  #{type => tuple, children => tuple_to_list(Tuple)}.

to_atom(Atom) ->
  list_to_atom(binary_to_list(?value(Atom))).

to_atom_map({Type, Line, _Value} = Atom) ->
  to_map({Type, Line, to_atom(Atom)}, literal).

to_mf(Mod, Fun) ->
  {to_atom(Mod), to_atom(Fun)}.
