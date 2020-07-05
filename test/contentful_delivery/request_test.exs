defmodule Contentful.RequestTest do
  use ExUnit.Case

  alias Contentful.Request

  describe "headers/1" do
    test "will construct the necessary headers for making a request with an api token" do
      assert [
               authorization: "Bearer api_access_token",
               "User-Agent": "Contentful Elixir SDK",
               accept: "application/json"
             ] == "api_access_token" |> Request.headers()
    end
  end
end
