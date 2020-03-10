defmodule Contentful.DeliveryTest do
  use ExUnit.Case
  doctest Contentful.Delivery

  test "greets the world" do
    assert Contentful.Delivery.hello() == :world
  end
end
