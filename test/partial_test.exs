defmodule HyperjsonTest.Partial do
  use HyperjsonTestHelper

  parsetest "should call a namespaced partial", """
  %hyperjson_partial_test:bar {
    name: 'World'
  }
  """, "Hello, World"

  defpartial :hyperjson_partial_test, :bar, """
  'Hello, ' + $name
  """

end