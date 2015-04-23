defmodule HyperjsonTest.Condition do
  use HyperjsonTestHelper

  parsetest "should render a single arm condition (truthy)", """
  true ? 'Hello'
  """, "Hello"

  parsetest "should render a single arm condition (falsy)", """
  false ? 'Hello'
  """, :undefined

  parsetest "should render a double arm condition (truthy)", """
  true ? 'Hello' : 'World'
  """, "Hello"

  parsetest "should render a double arm condition (falsy)", """
  false ? 'Hello' : 'World'
  """, "World"
end