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
        {:ok, %Asset{meta_data: %{id: @asset_id}}} = @space_id |> Assets.fetch_one(@asset_id)
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
         ]} = @space_id |> Assets.fetch_all()
      end
    end
  end
end
