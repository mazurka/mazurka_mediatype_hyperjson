Nonterminals

object
array
comprehension
conditional
property
properties
expression
expressions
literal
variable
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
'{'
'}'
'['
']'
','
':'
'<-'
'||'
'?'
'('
')'
'.'
'#'
'/'
'+'
.

Rootsymbol expression.

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
  expression dotpath :
  dotpath('$1', '$2').
expression ->
  expression '+' expression :
  #{
    type => call,
    value => {global__, add},
    children => #{
      0 => '$1',
      1 => '$3'
    }
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
  call :
  '$1'.

object ->
  '{' '}' :
  #{
    type => map,
    line => ?line('$1'),
    children => #{}
  }.
object ->
  '{' properties '}' :
  #{
    type => map,
    line => ?line('$1'),
    children => format_properties('$2', #{})
  }.

array ->
  '[' ']' :
   #{
     type => list,
     line => ?line('$1'),
     children => #{}
   }.
array ->
  '[' expressions ']' :
  #{
    type => list,
    line => ?line('$1'),
    children => list_to_map('$2')
  }.

conditional ->
  expression '?' expression :
  #{
    type => 'cond',
    children => #{
      0 => '$1',
      1 => '$3'
    }
  }.
conditional ->
  expression '?' expression ':' expression :
  #{
    type => 'cond',
    children => #{
      0 => '$1',
      1 => '$3',
      2 => '$5'
    }
  }.

comprehension ->
  '[' expression '||' symbol '<-' expression ']' :
  #{
    type => comprehension,
    line => ?line('$1'),
    children => #{
      assignment => #{
        type => assign,
        value => ?value('$4'),
        children => #{
          0 => '$6'
        }
      },
      expression => '$2'
    }
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
    value => {global__, resolve},
    children => #{
      0 => to_map('$1', literal),
      1 => to_map('$3', literal)
    }
  }.

call ->
  funcall :
  '$1'.
call ->
  funcall hash :
  #{
    type => call,
    value => {internal__, 'append-hash'},
    children => #{
      0 => '$1',
      1 => '$2'
    }
  }.

funcall ->
  symbol ':' symbol '(' ')' :
  #{
    type => call,
    value => to_mf('$1', '$3'),
    children => #{}
  }.
funcall ->
  symbol ':' symbol '(' expressions ')' :
  #{
    type => call,
    value => to_mf('$1', '$3'),
    children => list_to_map('$5')
  }.

hash ->
  '#' path :
  #{
    type => list,
    line => ?line('$1'),
    children => list_to_map('$2')
  }.

path ->
  '/' symbol :
  [to_map('$2', literal)].
path ->
  '/' symbol path :
  [to_map('$2', literal) | '$3'].

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

-define(line(Tup), element(2, Tup)).
-define(value(Tup), element(3, Tup)).
-define(literal(Lit), maps:get(value, Lit)).

to_map({_, Line, Value}, Type) ->
  #{type => Type, line => Line, value => Value}.

dotpath(A, []) ->
  A;
dotpath(Parent, [Key|Rest]) ->
  dotpath(#{
    type => call,
    value => {global__, get},
    children => #{
      0 => Key,
      1 => Parent
    }
  }, Rest).

format_properties([], Map) ->
  Map;
format_properties([{Key, Expr}|KVs], Map) ->
  Map2 = maps:put(Key, Expr, Map),
  format_properties(KVs, Map2).

list_to_map(List) ->
  list_to_map(lists:reverse(List), #{}).
list_to_map([], Acc) ->
  Acc;
list_to_map([V|Rest], Acc) ->
  Acc2 = maps:put(length(Rest), V, Acc),
  list_to_map(Rest, Acc2).

to_mf(Mod, Fun) ->
  {list_to_atom(binary_to_list(?value(Mod))),
   list_to_atom(binary_to_list(?value(Fun)))}.
