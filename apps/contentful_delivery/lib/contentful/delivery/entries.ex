defmodule Contentful.Delivery.Entries do
  @moduledoc """
  Entries collects function around the reading of entries from spaces
  """
  alias Contentful.{Delivery, Entry, MetaData, Space}
  alias HTTPoison.Response

  @doc """
  fetch_one will fetch a single entry for a given space within an environment
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
    |> build_request(entry_id, env, api_key)
    |> Delivery.send_request()
    |> parse_response(&build_entry/1)
  end

  defp build_request(space_id, entry_id, env, api_key) do
    url = [
      "#{Delivery.url()}",
      "/spaces/#{space_id}",
      "/environments/#{env}",
      "/entries/#{entry_id}"
    ]

    {url, api_key |> Delivery.request_headers()}
  end

  defp parse_response({:ok, %Response{status_code: code, body: body}}, callback) do
    case code do
      200 ->
        body |> Delivery.json_library().decode! |> callback.()

      401 ->
        body |> Delivery.build_error(:unauthorized)

      404 ->
        body |> Delivery.build_error(:not_found)

      _ ->
        Delivery.build_error()
    end
  end

  defp build_entry(%{
         "fields" => fields,
         "sys" => %{"id" => id, "revision" => rev}
       }) do
    %Entry{
      fields: fields,
      meta_data: %MetaData{id: id, revision: rev}
    }
  end
end
