defmodule Contentful.DeliveryTest do
  use ExUnit.Case
  doctest Contentful.Delivery

  test "can ask for it's json lib" do
    assert Contentful.Delivery.json_library() == Jason
  end
end
