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
    :ok
  end

  describe ".one" do
    test "will fetch one space" do
      use_cassette "space" do
        {:ok, %Space{name: "testspace"}} = Spaces.one(@space_id, @access_token)
      end
    end
  end
end
