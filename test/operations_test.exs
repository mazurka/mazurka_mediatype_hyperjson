defmodule HyperjsonTest.BIF do
  use HyperjsonTestHelper

  parsetest "should use the 'add' bif on two integers", """
  1 + 2
  """, 3

  parsetest "should use the 'add' bif on a float and an integer", """
  1 + 3.0
  """, 4.0

  parsetest "should use the 'add' bif to merge two objects", """
  {foo: 'bar'} + {'baz': 'bang'}
  """, %{"foo" => "bar",
         "baz" => "bang"}

  parsetest "should use the 'not' bif", """
  [
    !true
    !false
    !null
    !'foobar'
    !{}
    ![]
    !0
    !1
  ]
  """, [false, true, true, false,
        false, false, false, false]

  parsetest "should support || operation", """
  [
    'bar' || false
    true || false
    false || false
    false || 'foo'
    false || null
  ]
  """, ["bar", true, false, "foo", nil]

  parsetest "should support && operation", """
  [
    true && false
    false && false
    false && 'foo'
    false && null
    true && 'foo'
  ]
  """, [false, false, false, false, "foo"]

  parsetest "should use the equality bifs", """
  first = 'foo' == 'bar'
  second = 1 != 2

  first && second
  """, false
end