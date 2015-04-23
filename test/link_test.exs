defmodule HyperjsonTest.Link do
  use HyperjsonTestHelper

  parsetest "should support links", """
  out = {
    account: @res_users_read('123')
  }
  out
  """, %{"account" => %{"href" => "/123"}}

  parsetest "should append hashes to links", """
  out = {
    account: @res_users_read('123')#/name
  }
  out
  """, %{"account" => %{"href" => "/123#/name"}}

  parsetest "should append hashes to links with expressions", """
  name = 'name'
  out = {
    account: @res_users_read('123')#/(name + '-path')
    owner: @res_users_read('123')#/(name + '-path')/owner/name
  }
  out
  """, %{"account" => %{"href" => "/123#/name-path"},
         "owner" => %{"href" => "/123#/name-path/owner/name"}}

  parsetest "should support a relative hash", """
  [
    each network in ['twitter', 'facebook'] ->
      #/social/(network)
  ]
  """, [%{"href" => "#/social/twitter"}, %{"href" => "#/social/facebook"}]
end