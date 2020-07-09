defmodule Contentful.RequestTest do
  use ExUnit.Case

  alias Contentful.Request

  doctest Contentful.Request

  describe "headers/1" do
    test "will construct the necessary headers for making a request with an api token" do
      assert [
               authorization: "Bearer api_access_token",
               "User-Agent": "Contentful Elixir SDK",
               "X-Contentful-User-Agent": "Contentful Elixir SDK",
               accept: "application/json"
             ] == "api_access_token" |> Request.headers()
    end
  end

  describe "collection_query_params/1" do
    test "omits arbitrary keywords" do
      [limit: 1, skip: 2] = Request.collection_query_params(limit: 1, skip: 2)
    end

    test "raises an error for unknown modifiers" do
      assert_raise(ArgumentError, fn ->
        Request.collection_query_params(select_params: [id: [foo: "bar"]])
      end)
    end

    test "translates id into sys.id" do
      [{:"sys.id", "foo"}] = Request.collection_query_params(select_params: [id: "foo"])
    end

    test "supports modifiers" do
      [{:"fields.name[ne]", "bar"}] =
        Request.collection_query_params(select_params: [name: [ne: "bar"]])
    end

    test "supports translation of array properties" do
      [{:"fields.tags[nin]", "foo,bar,barfoo"}] =
        Request.collection_query_params(select_params: [tags: [nin: ["foo", "bar", "barfoo"]]])
    end
  end
end
