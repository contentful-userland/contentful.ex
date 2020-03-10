defmodule Contentful.ManagementTest do
  use ExUnit.Case
  doctest Contentful.Management

  test "greets the world" do
    assert Contentful.Management.hello() == :world
  end
end
