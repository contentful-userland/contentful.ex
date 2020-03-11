defmodule ContentfulTest do
  use ExUnit.Case
  doctest Contentful

  test "greets the world" do
    assert Contentful.hello() == :world
  end
end
