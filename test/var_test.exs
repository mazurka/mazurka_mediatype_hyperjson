defmodule HyperjsonTest.Var do
  use HyperjsonTestHelper

  parsetest "should assign a scalar variable", """
  var = 1
  var
  """, 1

  parsetest "should assign a complex variable", """
  var = {
    foo: {
      bar: [
        {
          1: 2,
          3: 4
        }
      ]
    }
  }
  var
  """, %{"foo" => %{"bar" => [%{1 => 2, 3 => 4}]}}

  parsetest "should assign a function call", """
  var = test:passthrough(1,2,3,4)
  var
  """, [1,2,3,4]

  parsetest "should use a variable in a nested structure", """
  var = 1
  [[[[[var]]]]]
  """, [[[[[1]]]]]

  parsetest "should use a qualified variable", """
  input/name
  """, ["input", "name"]

  parsetest "should support dot-paths", """
  foo = {
    bar: {
      baz: {
        value: 1
      }
    }
  }
  foo.bar.baz.value
  """, 1

  parsetest "should support dot-path expressions", """
  foo = {
    bar: {
      baz: {
        value: 1
      }
    }
  }
  val = 'value'
  foo.('b' + 'ar').('baz').(val)
  """, 1
end