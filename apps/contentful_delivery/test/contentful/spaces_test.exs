defmodule Contentful.Delivery.SpacesTest do
  use ExUnit.Case

  alias Contentful.Space
  alias Contentful.Delivery.Spaces

  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  @space_id "z3aswf9egfi8"
  @access_token "AN_ACCESS_TOKEN"

  setup_all do
    HTTPoison.start()
  end

  setup do
    ExVCR.Config.cassette_library_dir("../../fixture/vcr_cassettes")
    ExVCR.Config.filter_request_headers("authorization")
    :ok
  end

  describe ".fetch_one" do
    test "will fetch one space" do
      use_cassette "space" do
        {:ok, %Space{name: "testspace", meta_data: %{id: id}}} =
          Spaces.fetch_one(@space_id, @access_token)

        assert id == @space_id
      end
    end

    test "will give an error upon requesting a non existing space" do
      use_cassette "non existing space" do
        {:error, :not_found, original_message: _} = Spaces.fetch_one("foobarfoo", @access_token)
      end
    end

    test "will give an error indicating wrong credentials" do
      use_cassette "non accessible space" do
        {:error, :unauthorized, original_message: _} = Spaces.fetch_one(@space_id, "fooo")
      end
    end
  end
end
