defmodule Contentful.PreviewTest do
  use ExUnit.Case
  doctest Contentful.Preview

  test "greets the world" do
    assert Contentful.Preview.hello() == :world
  end
end
