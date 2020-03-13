defmodule Contentful.Delivery.ContentTypesTest do
  use ExUnit.Case

  alias Contentful.{ContentType, MetaData, Space}
  alias Contentful.Delivery.ContentTypes

  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  @space_id "bmehzfuz4raf"
  @access_token nil

  setup_all do
    HTTPoison.start()
  end

  setup do
    # ExVCR.Config.cassette_library_dir("../../fixture/vcr_cassettes")
    ExVCR.Config.filter_request_headers("authorization")
    :ok
  end

  describe ".fetch_all" do
    test "fetches a set of content types to a space" do
      use_cassette "multiple_content_types" do
        space = %Space{meta_data: %MetaData{id: @space_id}}

        {:ok, [%ContentType{description: "A product model"} | _]} =
          ContentTypes.fetch_all(space, "master", @access_token)
      end
    end
  end

  describe ".fetch_one" do
    test "fetches a single content type by id for a given space" do
      use_cassette "single_content_type" do
        {:ok, %ContentType{description: "A product model"}} =
          ContentTypes.fetch_one(@space_id, "product", "master", @access_token)
      end
    end
  end
end
