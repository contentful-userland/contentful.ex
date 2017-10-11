defmodule Contentful.Functions do
  @moduledoc "Functions for interacting with Contentful API"
  
  @callback process_url(String.t) :: String.t
  
  defmacro __using__(_params) do
    quote do
      require Logger
      use HTTPoison.Base
      @behaviour Contentful.Functions
      def space(space_id, access_token) do
        space_url = "/spaces/#{space_id}"
    
        contentful_request(
          space_url,
          access_token
        )
      end
    
      def entries(space_id, access_token, params \\ %{}) do
        entries_url = "/spaces/#{space_id}/entries"
    
        response = contentful_request(
          entries_url,
          access_token,
          Map.delete(params, "resolve_includes"))
    
        cond do
          params["resolve_includes"] == false ->
            response["items"]
          true ->
            response
            |> Contentful.IncludeResolver.resolve_entry
            |> Map.fetch!("items")
        end
      end
    
      def entry(space_id, access_token, entry_id, params \\ %{}) do
        entries = entries(space_id, access_token, Map.merge(params, %{'sys.id' => entry_id}))
        entries |> Enum.fetch!(0)
      end
    
      def assets(space_id, access_token, params \\ %{}) do
        assets_url = "/spaces/#{space_id}/assets"
    
        contentful_request(
          assets_url,
          access_token,
          params
        )["items"]
      end
    
      def asset(space_id, access_token, asset_id, params \\ %{}) do
        asset_url = "/spaces/#{space_id}/assets/#{asset_id}"
    
        contentful_request(
          asset_url,
          access_token,
          params
        )
      end
    
      def content_types(space_id, access_token, params \\ %{}) do
        content_types_url = "/spaces/#{space_id}/content_types"
    
        contentful_request(
          content_types_url,
          access_token,
          params
        )["items"]
      end
    
      def content_type(space_id, access_token, content_type_id, params \\ %{}) do
        content_type_url = "/spaces/#{space_id}/content_types/#{content_type_id}"
    
        contentful_request(
          content_type_url,
          access_token,
          params
        )
      end
    
      def contentful_request(uri, access_token, params \\ %{}) do
        final_url = format_path(path: uri, params: params)
    
        Logger.debug "GET #{final_url}"
    
        get!(final_url, client_headers(access_token)).body
      end
    
      defp client_headers(access_token) do
        [
          {"authorization", "Bearer #{access_token}"},
          {"Accept", "application/json"},
          {"User-Agent", "Contentful-Elixir"}
        ]
      end
    
      defp format_path(path: path, params: params) do
        if Enum.any?(params) do
          query = params
          |> Enum.reduce("", fn ({k, v}, acc) -> acc <> "#{k}=#{v}&" end)
          |> String.trim_trailing("&")
          "#{path}/?#{query}"
        else
          path
        end
      end
    
      defp process_response_body(body) do
        body
        |> Poison.decode!
      end
    end

    #defoverridable [space: 0, entry: 0, entries: 0, assets: 0, asset: 0, content_types: 0, content_type: 0, contentful_request: 0, client_headers: 0, format_path: 0, process_url: 0, process_response_body: 0]
    #defoverridable [space: 0, entry: 0, entries: 0, assets: 0, asset: 0, content_types: 0, content_type: 0, contentful_request: 0]
    
  end
  

end