defmodule HyperjsonTest.Literal do
  use HyperjsonTestHelper

  parsetest "should render a integer", """
  101293
  """, 101293

  parsetest "should render a float", """
  101.293
  """, 101.293

  parsetest "should render a string with single quotes", """
  'Hello!'
  """, "Hello!"

  parsetest "should render a string with double quotes", """
  "Hello!"
  """, "Hello!"

  parsetest "should render a unicode string", """
  '☃'
  """, "☃"

  parsetest "should render true", """
  true
  """, true

  parsetest "should render false", """
  false
  """, false

  parsetest "should render null", """
  null
  """, nil
end