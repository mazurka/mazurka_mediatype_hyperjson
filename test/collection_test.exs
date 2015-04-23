defmodule HyperjsonTest.Collection do
  use HyperjsonTestHelper

  parsetest "should render an empty list", """
  []
  """, []

  parsetest "should render an empty map", """
  {}
  """, %{"href" => "/should-render-an-empty-map"}

  parsetest "should render a flat list", """
  [
    1
    3.14
    "Hello"
    "World"
  ]
  """, [1, 3.14, "Hello", "World"]

  parsetest "should render a flat map", """
  {
    name: 'Joe'
    address: '123 Fake St'
  }
  """, %{"name" => "Joe",
         "address" => "123 Fake St",
        "href" => "/should-render-a-flat-map"}

  parsetest "should render a deep list", """
  [
    'one'
    [
      'two'
      [
        'three'
        true
        false
        null
      ]
    ]
  ]
  """, ["one", ["two", ["three", true, false, nil]]]

  parsetest "should render a deep map", """
  {
    one: {
      two: {
        three: {
          foo: true
          bar: false
          baz: null
        }
      }
    }
  }
  """, %{
    "href" => "/should-render-a-deep-map",
    "one" => %{
      "two" => %{
        "three" => %{
          "foo" => true,
          "bar" => false,
          "baz" => nil
        }
      }
    }
  }

  parsetest "should render a map with unicode keys", """
  {
    "☃": "💩"
  }
  """, %{"href" => "/should-render-a-map-with-unicode-keys",
         "☃" => "💩"}

  parsetest "should allow expressions inside of objects", """
  key = 'foo'
  out = {(key): 'bar'}
  out
  """, %{"foo" => "bar"}
end