defmodule HyperjsonTest.Comprehension do
  use HyperjsonTestHelper

  parsetest "should render an empty list comprehension", """
  [
    each val in [] ->
      val
  ]
  """, []

  parsetest "should render an empty map comprehension", """
  {
    each val in [] ->
      ('key-' + to_string(val)): val
  }
  """, %{}

  parsetest "should render a literal list comprehension", """
  [
    each val in [1,2,3] ->
      val + 1
  ]
  """, [2,3,4]

  parsetest "should render a literal map comprehension", """
  {
    each val in [1,2,3] ->
      ('key-' + to_string(val)): val + 1
  }
  """, %{"key-1" => 2,
         "key-2" => 3,
         "key-3" => 4}

  parsetest "should render a literal list comprehension with keys", """
  [
    each val, i in [1,2,3] ->
      val + i
  ]
  """, [1,3,5]

  parsetest "should render a literal map comprehension with keys", """
  {
    each val, i in [1,2,3] ->
      (i): val
  }
  """, %{0 => 1,
         1 => 2,
         2 => 3}

  parsetest "should render perform a comprehension over Enums", """
  {
    each val, i in {"foo": "bar", "baz": "bang"} ->
      ('key-' + i): 'val-' + val
  }
  """, %{"key-foo" => "val-bar",
         "key-baz" => "val-bang"}

end