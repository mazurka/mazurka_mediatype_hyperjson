Definitions.

B = [01]
O = [0-7]
D = [0-9]
U = [A-Z]
L = [a-z]
I = \n?(\s\s|\t)
WS = (\s|\t|\r|\n|,)
C = ({U}|{L})
Delim = [\s,]*

Atom = [a-z@][0-9a-zA-Z_\-]*
Var = [A-Z_][0-9a-zA-Z_]*
NSVar = ({Var}|{Var}\/{Var})
Float = (\+|-)?[0-9]+\.[0-9]+((E|e)(\+|-)?[0-9]+)?

Rules.


%%% comment
\/\/.*                               :  skip_token.

\{                                   :  {token, {'{',
                                                 TokenLine}}.

\}                                   :  {token, {'}',
                                                 TokenLine}}.

\[                                   :  {token, {'[',
                                                 TokenLine}}.

\]                                   :  {token, {']',
                                                 TokenLine}}.

\:                                   :  {token, {':',
                                                 TokenLine}}.

\+                                   :  {token, {'+',
                                                 TokenLine}}.

\|\|                                 :  {token, {'||',
                                                 TokenLine}}.

\&\&                                 :  {token, {'&&',
                                                 TokenLine}}.

\,                                   :  {token, {',',
                                                 TokenLine}}.

\.                                   :  {token, {'.',
                                                 TokenLine}}.

\?                                   :  {token, {'?',
                                                 TokenLine}}.

\(                                   :  {token, {'(',
                                                 TokenLine}}.

\)                                   :  {token, {')',
                                                 TokenLine}}.

\!                                   :  {token, {'!',
                                                 TokenLine}}.

\#                                   :  {token, {'#',
                                                 TokenLine}}.

\/                                   :  {token, {'/',
                                                 TokenLine}}.

<\-                                  :  {token, {'<-',
                                                 TokenLine}}.

true                                 :  {token, {boolean,
                                                 TokenLine,
                                                 true}}.

false                                :  {token, {boolean,
                                                 TokenLine,
                                                 false}}.

\"[^\"]*\"                           :  {token, {string,
                                                TokenLine,
                                                parse_string(TokenChars)}}.

%%% numbers
{D}+                                 :  {token, {integer,
                                                TokenLine,
                                                list_to_integer(TokenChars)}}.
{Float}                              :  {token, {float,
                                                TokenLine,
                                                list_to_float(TokenChars)}}.

{Atom}                               :  {token, {atom,
                                                 TokenLine,
                                                 unicode(TokenChars)}}.

{Var}                                :  {token, {var,
                                                 TokenLine,
                                                 unicode(TokenChars)}}.

%%% whitespace
{WS}                                 :  skip_token.

Erlang code.

unicode(Str) ->
  unicode:characters_to_binary(Str).

parse_string(Str) ->
  Bin = unicode(Str),
  Len = byte_size(Bin) - 2,
  <<_, Content:Len/binary, _>> = Bin,
  Content.
