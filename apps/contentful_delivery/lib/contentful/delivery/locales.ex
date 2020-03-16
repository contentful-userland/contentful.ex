defmodule Contentful.Delivery.Locales do
  @moduledoc """
  Handles the fetching of locales within a given space
  """
  alias Contentful.{Delivery, Locale, Space}

  @doc """
  will attempt to fetch all locales for a given space
  """
  @spec fetch_all(Space.t() | String.t(), String.t(), String.t() | nil) ::
          list(Locale.t())
  def fetch_all(space, env \\ "master", api_key \\ nil)

  def fetch_all(%Space{meta_data: %{id: space_id}}, env, api_key) do
    space_id
    |> build_request(env, api_key)
    |> Delivery.send_request()
    |> Delivery.parse_response(&build_locales/1)
  end

  def fetch_all(space_id, env, api_key) do
    fetch_all(%Space{meta_data: %{id: space_id}}, env, api_key)
  end

  defp build_request(space, env, api_key) do
    url = [
      space |> Delivery.url(env),
      "/locales"
    ]

    {url, api_key |> Delivery.request_headers()}
  end

  defp build_locales(%{"items" => items}) do
    {:ok,
     items
     |> Enum.map(fn %{
                      "name" => name,
                      "code" => code,
                      "fallbackCode" => fallback_code
                    } ->
       %Locale{name: name, code: code, fallback_code: fallback_code}
     end)}
  end
end
