defmodule Contentful.Delivery.Locales do
  alias Contentful.{Delivery, Locale, Space}
  alias HTTPoison.Response

  @spec fetch_all(Space.t() | String.t(), String.t(), String.t() | nil) ::
          list(Locale.t())
  def fetch_all(space, env \\ "master", api_key \\ nil)

  def fetch_all(%Space{meta_data: %{id: space_id}}, env, api_key) do
    space_id
    |> build_request(env, api_key)
    |> Delivery.send_request()
    |> parse_response(&build_locales/1)
  end

  def fetch_all(space_id, env, api_key) do
    fetch_all(%Space{meta_data: %{id: space_id}}, env, api_key)
  end

  defp build_request(space_id, env, api_key) do
    url = [
      Delivery.url(),
      "/spaces/#{space_id}",
      "/environments/#{env}",
      "/locales"
    ]

    {url, api_key |> Delivery.request_headers()}
  end

  defp parse_response(
         {:ok, %Response{status_code: code, body: body}} = resp,
         callback
       ) do
    case code do
      200 ->
        body |> Delivery.json_library().decode! |> callback.()

      401 ->
        body |> Delivery.build_error(:unauthorized)

      404 ->
        body |> Delivery.build_error(:not_found)

      _ ->
        resp |> Delivery.build_error()
    end
  end

  defp parse_response({:error, _}, _callback) do
    Delivery.build_error()
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
