defmodule HyperjsonTest.Call do
  use HyperjsonTestHelper

  parsetest "should call a global function", """
  bar(1,2,3)
  """, [1,2,3]

  parsetest "should call a namespaced function", """
  foo:bar(1,2,3)
  """, [1,2,3]

  parsetest "should call nested functions", """
  first(1 second(2 fourth(4) fifth(5)) third(3 sixth(6) seventh(7)))
  """, [1, [2, [4], [5]], [3, [6], [7]]]

  parsetest "should call elixir-namespaced capital modules", """
  Enum:reverse(1,2,3)
  """, [3,2,1]

  parsetest "should convert '_' to '.'", """
  String_Chars:to_string([104, 101, 108, 108, 111])
  """, "hello"
end
