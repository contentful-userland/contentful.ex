defmodule Contentful.DeliveryTest do
  use ExUnit.Case
  doctest Contentful.Delivery
  alias Contentful.Delivery

  @moduledoc """
  General tips for testing

  1. The library can be configured with an api key for the function calls, keep it lean during tests, 
     i.e. you do not have to pass env and api token to every function call
  2. Most requests are recorded against an existing space, so if you rerecord, check the generated 
     json for changes
  3. You can put a config/secrets.test locally with a token only you have access to

  """

  describe ".json_library" do
    test "can ask for its json lib" do
      assert Delivery.json_library() == Jason
    end
  end

  describe ".url" do
    test "no parameters will return the base url and protocol" do
      assert "https://cdn.contentful.com" == Delivery.url()
    end

    test "with the first parameter will return a space url" do
      assert "https://cdn.contentful.com/spaces/foobar" ==
               Delivery.url("foobar")
    end

    test "with the first and second parameter will return a space url with an environment" do
      assert "https://cdn.contentful.com/spaces/foobar/environments/baz" ==
               Delivery.url("foobar", "baz")
    end
  end

  describe ".request_headers" do
    test "will construct the necessary headers for making a request with an api token" do
      assert [
               authorization: "Bearer api_access_token",
               "User-Agent": "Contentful Elixir SDK",
               accept: "application/json"
             ] == "api_access_token" |> Delivery.request_headers()
    end
  end
end
