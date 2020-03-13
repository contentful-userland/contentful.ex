defmodule Contentful.Delivery.EntriesTest do
  use ExUnit.Case
  alias Contentful.{Entry, MetaData, Space}
  alias Contentful.Delivery.Entries

  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  @space_id "bmehzfuz4raf"
  @entry_id "5UeyMKZrmqMYyMMJvCP3Ls"
  @access_token nil

  setup_all do
    HTTPoison.start()
  end

  setup do
    ExVCR.Config.filter_request_headers("authorization")
    :ok
  end

  describe ".fetch_one" do
    test "will fetch one entry from the given space" do
      use_cassette "single entry" do
        {:ok, %Entry{fields: _, meta_data: %MetaData{id: @entry_id}}} =
          @space_id |> Entries.fetch_one(@entry_id, "master", @access_token)
      end
    end
  end

  describe ".fetch_all" do
    test "will fetch all published entries for a given space" do
      use_cassette "multiple entries" do
        {:ok, [%Entry{}, %Entry{}]} = %Space{meta_data: %{id: @space_id}} |> Entries.fetch_all()
      end
    end
  end
end
