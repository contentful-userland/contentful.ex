defmodule Contentful.PreviewTest do
  use ExUnit.Case
  alias Contentful.Preview
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  alias ExVCR.Config, as: VCR

  @access_token  "ACCESS_TOKEN"
  @space_id      "z3aswf9egfi8"

  setup_all do
    HTTPoison.start
    VCR.cassette_library_dir("fixture/vcr_cassettes/preview")
    :ok
  end

  @tag timeout: 10000
  test "entries" do
    VCR.filter_request_headers("authorization")
    use_cassette "entries" do
      entries = Preview.entries(@space_id, @access_token)
      assert is_list(entries)
    end
  end

  @tag timeout: 10000
  test "search entry with includes" do
    VCR.filter_request_headers("authorization")
    use_cassette "single_entry_with_includes" do
      space_id = "if4k9hkjacuz"
      entries = Preview.entries(space_id, @access_token, %{
            "content_type" => "6pFEhaSgDKimyOCE0AKuqe",
            "fields.slug" => "test-page",
            "include" => "10"}
      )
      assert is_list(entries)
    end
  end

  @tag timeout: 10000
  test "entry" do
    VCR.filter_request_headers("authorization")
    use_cassette "entry" do
      entry = Preview.entry(@space_id, @access_token, "5JQ715oDQW68k8EiEuKOk8")

      assert is_map(entry["fields"])
    end
  end

  test "content_types" do
    VCR.filter_request_headers("authorization")
    use_cassette "content_types" do
      first_content_type = Preview.content_types(@space_id, @access_token)
      |> List.first

      assert is_list(first_content_type["fields"])
    end
  end

  test "content_type" do
    VCR.filter_request_headers("authorization")
    use_cassette "content_type" do
      content_type = Preview.content_type(@space_id, @access_token, "1kUEViTN4EmGiEaaeC6ouY")

      assert is_list(content_type["fields"])
    end
  end

  test "assets" do
    VCR.filter_request_headers("authorization")
    use_cassette "assets" do
      first_asset = Preview.assets(@space_id, @access_token)
      |> List.first

      assert is_map(first_asset["fields"])
    end
  end

  test "asset" do
    VCR.filter_request_headers("authorization")
    use_cassette "asset" do
      asset = Preview.asset(@space_id, @access_token, "2ReMHJhXoAcy4AyamgsgwQ")
      fields = asset["fields"]

      assert is_map(fields)
    end
  end

  test "space" do
    VCR.filter_request_headers("authorization")
    use_cassette "space" do
      space = Preview.space(@space_id, @access_token)
      locales = space["locales"]
      |> List.first

      assert locales["code"] == "en-US"
    end
  end
end
