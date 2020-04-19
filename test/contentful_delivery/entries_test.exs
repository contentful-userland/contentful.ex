defmodule Contentful.Delivery.EntriesTest do
  use ExUnit.Case

  alias Contentful.Delivery.Entries
  alias Contentful.{Entry, Space, SysData}

  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  @space_id "bmehzfuz4raf"
  @entry_id "5UeyMKZrmqMYyMMJvCP3Ls"
  @env "master"
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
        {:ok, %Entry{fields: _, sys: %SysData{id: @entry_id}}} =
          @entry_id |> Entries.fetch_one(@space_id, @env, @access_token)
      end
    end
  end

  describe ".fetch_all" do
    test "will fetch all published entries for a given space" do
      use_cassette "multiple entries" do
        {:ok, [%Entry{}, %Entry{}], total: 2} = Entries.fetch_all([], %Space{sys: %{id: @space_id}})
      end
    end

    test "will fetch all published entries for a space, respecting the limit parameter" do
      use_cassette "multiple entries, limit filter" do
        {:ok, [%Entry{fields: %{"name" => "Purple Thunder"}}], total: 2} =
          Entries.fetch_all([limit: 1], %Space{sys: %{id: @space_id}})
      end
    end

    test "will fetch all published entries for a space, respecting the skip param" do
      use_cassette "multiple entries, skip filter" do
        {:ok, [%Entry{fields: %{"name" => "Blue steel"}}], total: 2} =
          Entries.fetch_all(
            [skip: 1],
            %Space{sys: %{id: @space_id}},
            @env
          )
      end
    end

    test "will fetch fetch all published entries for a space, respecting both the skip and the limit param" do
      use_cassette "multiple entries, all filters" do
        {:ok, [%Entry{fields: %{"name" => "Blue steel"}}], total: 2} =
          Entries.fetch_all(
            [skip: 1, limit: 1],
            %Space{sys: %{id: @space_id}},
            @env,
            @access_token
          )
      end
    end
  end
end
