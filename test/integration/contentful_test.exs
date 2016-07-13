defmodule Contentful.DeliveryTest do
  use ExUnit.Case
  alias Contentful.Delivery

  @access_token  "560976a1d0e918455da2c5000600f2e7fcdd6ad6d3a0b627b8c8c61ed93ac398"
  @space_id      "z3aswf9egfi8"

  test "entries" do
    entries = Delivery.entries(@space_id, @access_token)
    assert is_list(entries)
  end

  test "entry" do
    entry = Delivery.entry(@space_id, @access_token, "5JQ715oDQW68k8EiEuKOk8")

    assert is_map(entry["fields"])
  end

  test "content_types" do
    first_content_type = Delivery.content_types(@space_id, @access_token)
    |> List.first

    assert is_list(first_content_type["fields"])
  end

  test "content_type" do
    content_type = Delivery.content_type(@space_id, @access_token, "1kUEViTN4EmGiEaaeC6ouY")

    assert is_list(content_type["fields"])
  end

  test "assets" do
    first_asset = Delivery.assets(@space_id, @access_token)
    |> List.first

    assert is_map(first_asset["fields"])

  end

  test "asset" do
    asset = Delivery.asset(@space_id, @access_token, "2ReMHJhXoAcy4AyamgsgwQ")
    fields = asset["fields"]

    assert is_map(fields)
  end

  test "space" do
    space = Delivery.space(@space_id, @access_token)
    locales = space["locales"]
    |> List.first

    assert locales["code"] == "en-US"
  end
end
