defmodule Contentful.IncludeResolverTest do
  use ExUnit.Case
  alias Contentful.Delivery
  alias Contentful.IncludeResolver
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  @access_token  "ACCESS_TOKEN"
  @space_id      "z3aswf9egfi8"

  setup_all do
    HTTPoison.start
  end

  @tag timeout: 10000
  test "entries" do
    use_cassette "entries" do
      entries =
        Delivery.entries(@space_id, @access_token)
        |> IncludeResolver.resolve_entry

      assert is_list(entries["items"])
    end
  end

  @tag timeout: 10000
  test "search entry with includes" do
    use_cassette "single_entry_with_includes" do
      space_id = "if4k9hkjacuz"
      entries = Delivery.entries(space_id, @access_token, %{
            "content_type" => "6pFEhaSgDKimyOCE0AKuqe",
            "fields.slug" => "test-page",
            "include" => "10"})
      |> IncludeResolver.resolve_entry

      assert is_list(entries["items"])
    end
  end


  @tag timeout: 10000
  test "entry" do
    use_cassette "entry" do
      entry = Delivery.entry(@space_id, @access_token, "5JQ715oDQW68k8EiEuKOk8")
      |> IncludeResolver.resolve_entry

      assert is_map(entry["item"])
    end
  end
end
