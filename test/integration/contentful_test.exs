defmodule Contentful.DeliveryTest do
  use ExUnit.Case
  alias Contentful.Delivery
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  @access_token "ACCESS_TOKEN"
  @space_id "z3aswf9egfi8"

  setup_all do
    HTTPoison.start()
  end

  describe ".entries" do
    @tag timeout: 10000
    test "fetches entries successfully with valid space_id & access_token" do
      use_cassette "entries" do
        assert {:ok,
                %{
                  "items" => items,
                  "limit" => 100,
                  "skip" => 0,
                  "total" => 6
                }} = Delivery.entries(@space_id, @access_token)

        assert is_list(items)
      end
    end

    test "handles unauthorized error from invalid access_token" do
      use_cassette "entries_401" do
        assert {:error, :not_authorized} == Delivery.entries(@space_id, "bladjksflaksdjflkjkl")
      end
    end

    test "handles not found error from invalid space_id" do
      use_cassette "entries_404" do
        assert {:error, :not_found} == Delivery.entries("", @access_token)
      end
    end
  end

  @tag timeout: 10000
  test "search entry with includes" do
    use_cassette "single_entry_with_includes" do
      space_id = "if4k9hkjacuz"

      {:ok, %{"items" => entries}} =
        Delivery.entries(space_id, @access_token, %{
          "content_type" => "6pFEhaSgDKimyOCE0AKuqe",
          "fields.slug" => "test-page",
          "include" => "10"
        })

      assert is_list(entries)
    end
  end

  @tag timeout: 10000
  test "entry" do
    use_cassette "entry" do
      entry = Delivery.entry(@space_id, @access_token, "5JQ715oDQW68k8EiEuKOk8")

      assert is_map(entry["fields"])
    end
  end

  test "content_types" do
    use_cassette "content_types" do
      {:ok, %{"items" => [first_content_type | _]}} =
        Delivery.content_types(@space_id, @access_token)

      assert is_list(first_content_type["fields"])
    end
  end

  test "content_type" do
    use_cassette "content_type" do
      {:ok, content_type} =
        Delivery.content_type(@space_id, @access_token, "1kUEViTN4EmGiEaaeC6ouY")

      assert is_list(content_type["fields"])
    end
  end

  test "assets" do
    use_cassette "assets" do
      {:ok, %{"items" => [first_asset | _]}} = Delivery.assets(@space_id, @access_token)

      assert is_map(first_asset["fields"])
    end
  end

  test "asset" do
    use_cassette "asset" do
      {:ok, asset} = Delivery.asset(@space_id, @access_token, "2ReMHJhXoAcy4AyamgsgwQ")
      fields = asset["fields"]

      assert is_map(fields)
    end
  end

  test "space" do
    use_cassette "space" do
      {:ok, space} = Delivery.space(@space_id, @access_token)

      locales =
        space["locales"]
        |> List.first()

      assert locales["code"] == "en-US"
    end
  end
end
