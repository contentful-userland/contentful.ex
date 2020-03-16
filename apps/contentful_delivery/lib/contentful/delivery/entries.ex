defmodule Contentful.Delivery.Entries do
  @moduledoc """
  Entries collects function around the reading of entries from spaces
  """
  alias Contentful.{Delivery, Entry, MetaData, Space}

  @doc """
  will fetch a single entry for a given space within an environment
  """
  @spec fetch_one(
          Space.t() | String.t(),
          String.t(),
          String.t(),
          String.t() | nil
        ) ::
          {:ok, Entry.t()}
          | {:error, atom(), original_message: String.t()}
          | {:error, :unknown}
  def fetch_one(space_id, entry_id, env \\ "master", api_key \\ nil)

  def fetch_one(%Space{meta_data: %{id: space_id}}, entry_id, env, api_key) do
    space_id
    |> build_single_request(entry_id, env, api_key)
    |> Delivery.send_request()
    |> Delivery.parse_response(&build_entry/1)
  end

  def fetch_one(space_id, entry_id, env, api_key) do
    fetch_one(%Space{meta_data: %{id: space_id}}, entry_id, env, api_key)
  end

  @doc """
  will fetch all entries associated with a space __that are **published**__
  """
  @spec fetch_all(Space.t(), list(keyword()), String.t(), String.t() | nil) ::
          {:ok, list(Entry.t())}
          | {:error, atom(), original_message: String.t()}
          | {:error, :unknown}
  def fetch_all(space, options \\ [], env \\ "master", api_key \\ nil)

  def fetch_all(%Space{meta_data: %{id: space_id}}, options, env, api_key) do
    space_id
    |> build_multi_request(options, env, api_key)
    |> Delivery.send_request()
    |> Delivery.parse_response(&build_entries/1)
  end

  def fetch_all(space_id, options, env, api_key) when is_binary(space_id) do
    fetch_all(%Space{meta_data: %{id: space_id}}, options, env, api_key)
  end

  defp build_single_request(space_id, entry_id, env, api_key) do
    url = [
      space_id |> Delivery.url(env),
      "/entries/#{entry_id}"
    ]

    {url, api_key |> Delivery.request_headers()}
  end

  defp build_multi_request(space, options, env, api_key) do
    url = [
      space |> Delivery.url(env),
      "/entries",
      options |> Delivery.collection_query_params()
    ]

    {url, api_key |> Delivery.request_headers()}
  end

  defp build_entries(%{"sys" => %{"type" => "Array"}, "items" => items}) do
    {:ok, items |> Enum.map(&build_entry/1) |> Enum.map(fn {:ok, entry} -> entry end)}
  end

  defp build_entry(%{
         "fields" => fields,
         "sys" => %{"id" => id, "revision" => rev}
       }) do
    {:ok,
     %Entry{
       fields: fields,
       meta_data: %MetaData{id: id, revision: rev}
     }}
  end
end
