defmodule Contentful.Delivery do
  @moduledoc """
  A HTTP client for Contentful.
  This module contains the functions to interact with Contentful's read-only
  Content Delivery API.
  """

  require Logger
  use HTTPoison.Base

  @endpoint "cdn.contentful.com"
  @protocol "https"

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
      params
    )

    response["items"]
  end

  def entry(space_id, access_token, entry_id, params \\ %{}) do
    entry_url = "/spaces/#{space_id}/entries/#{entry_id}"

    contentful_request(
      entry_url,
      access_token,
      params
    )
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

  defp contentful_request(uri, access_token, params \\ %{}) do
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
        |> String.rstrip(?&)
      "#{path}/?#{query}"
    else
      path
    end
  end

  defp process_url(url) do
    "#{@protocol}://#{@endpoint}#{url}"
  end

  defp process_response_body(body) do
    body
    |> Poison.decode!
    |> resolve_includes
  end

  defp merge_includes(response, includes) do
    all_includes = %{
      "Asset" => includes["Asset"],
      "Entry" => Enum.concat(
        Dict.get(response, "items", []),
        Dict.get(includes, "Entry", [])
      )
    }

    items = if Dict.has_key?(response, "items") do
      Enum.map(
        Dict.get(response, "items"), fn (item) ->
          resolve_include(
            item,
            all_includes
          )
        end
      )
    end

    Dict.merge(response, %{"items" => items})
  end

  defp resolve_includes(response) do
    if Dict.has_key?(response, "items") do
      includes = Dict.get(response, "includes")
      cond do
        is_map(includes) -> merge_includes(response, includes)
        true -> response
      end
    else
      response
    end
  end

  defp resolve_include(item, includes) do
    if item["sys"]["type"] == "Entry" do
      resolver = fn
        {name, field} -> {name, resolve_include_field(field, includes)}
      end
      fields = item["fields"]
      |> Enum.map(resolver)

      Dict.merge(item, %{"fields" => fields})
    else
      item
    end
  end

  defp resolve_include_field(field, includes) when is_map(field) do
    if Dict.has_key?(field, "sys") && field["sys"]["type"] == "Link" do
      if Dict.has_key?(includes, field["sys"]["linkType"]) do
        includes[field["sys"]["linkType"]]
        |> Enum.find(fn (match) -> match["sys"]["id"] == field["sys"]["id"] end)
      else
        field
      end
    else
      field
    end
  end

  defp resolve_include_field(field, _includes), do: field
end
