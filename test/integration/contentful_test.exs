defmodule Contentful.DeliveryTest do
  use ExUnit.Case
  alias Contentful.Delivery
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  @access_token  "ACCESS_TOKEN"
  @space_id      "z3aswf9egfi8"

  setup_all do
    HTTPoison.start
  end

  test "entries" do
    use_cassette "entries" do
      entries = Delivery.entries(@space_id, @access_token)
      assert is_list(entries)
    end
  end

  test "search entry with includes" do
    space_id = "if4k9hkjacuz"
    access_token = "707769d3f940e0d1981da3953afdb460a102c57b3729eef8b3644690832cf73d"

    entries = Delivery.entries(space_id, access_token, %{
          "content_type" => "6pFEhaSgDKimyOCE0AKuqe",
          "fields.slug" => "test-page",
          "include" => "10"}
    )
    assert is_list(entries)
  end

  test "entry" do
    use_cassette "entry" do
     entry = Delivery.entry(@space_id, @access_token, "5JQ715oDQW68k8EiEuKOk8")

      assert is_map(entry["fields"])
    end
  end

  test "content_types" do
    use_cassette "content_types" do
      first_content_type = Delivery.content_types(@space_id, @access_token)
      |> List.first

      assert is_list(first_content_type["fields"])
    end
  end

  test "content_type" do
    use_cassette "content_type" do
      content_type = Delivery.content_type(@space_id, @access_token, "1kUEViTN4EmGiEaaeC6ouY")

      assert is_list(content_type["fields"])
    end
  end

  test "assets" do
    use_cassette "assets" do
      first_asset = Delivery.assets(@space_id, @access_token)
      |> List.first

      assert is_map(first_asset["fields"])
    end
  end

  test "asset" do
    use_cassette "asset" do
      asset = Delivery.asset(@space_id, @access_token, "2ReMHJhXoAcy4AyamgsgwQ")
      fields = asset["fields"]

      assert is_map(fields)
    end
  end

  test "space" do
    use_cassette "space" do
      space = Delivery.space(@space_id, @access_token)
      locales = space["locales"]
      |> List.first

      assert locales["code"] == "en-US"
    end
  end
end
