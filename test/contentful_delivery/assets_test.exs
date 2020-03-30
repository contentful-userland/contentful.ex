defmodule Contentful.Delivery.AssetsTest do
  use ExUnit.Case
  alias Contentful.Asset
  alias Contentful.Delivery.Assets

  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  @space_id "bmehzfuz4raf"
  @asset_id "577fpmbIfYD71VCjCpYA84"

  setup_all do
    HTTPoison.start()
  end

  setup do
    ExVCR.Config.filter_request_headers("authorization")
    :ok
  end

  describe ".fetch_one" do
    test "fetches a single asset by it's id from a space" do
      use_cassette "single asset" do
        {:ok, %Asset{meta_data: %{id: @asset_id}}} =
          @asset_id |> Assets.fetch_one(@space_id)
      end
    end
  end

  describe ".fetch_all" do
    test "fetches all assets for a given space" do
      use_cassette "multiple assets" do
        {:ok,
         [
           %Asset{fields: %{file: %{content_type: "application/pdf"}}},
           %Asset{fields: %{file: %{content_type: "image/png"}}}
         ], total: 2} = Assets.fetch_all([], @space_id)
      end
    end

    test "will fetch all published entries for a space, respecting the limit parameter" do
      use_cassette "multiple assets, limit filter" do
        {:ok, [%Asset{fields: %{title: "bafoo"}}], total: 2} =
          Assets.fetch_all([limit: 1], @space_id)
      end
    end

    test "will fetch all published entries for a space, respecting the skip param" do
      use_cassette "multiple assets, skip filter" do
        {:ok, [%Asset{fields: %{title: "Foobar"}}], total: 2} =
          Assets.fetch_all([skip: 1], @space_id)
      end
    end

    test "will fetch fetch all published entries for a space, respecting both the skip and the limit param" do
      use_cassette "multiple assets, all filters" do
        {:ok, [%Asset{fields: %{title: "Foobar"}}], total: 2} =
          Assets.fetch_all([skip: 1, limit: 1], @space_id)
      end
    end
  end

  describe ".stream" do
    test "streams asset calls" do
      use_cassette "multiple assets, limit filter, streamed" do
        [%Asset{}, %Asset{}] =
          Assets.stream([limit: 1], @space_id) |> Enum.to_list()
      end
    end
  end
end
