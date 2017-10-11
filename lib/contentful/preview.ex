defmodule Contentful.Preview do
  @moduledoc """
  A HTTP client for Contentful Preview Endpoint.
  This module connects to the preview.contentful.com and uses the preview access token
  """

  use Contentful.Functions

  @endpoint "preview.contentful.com"
  @protocol "https"

  defp process_url(url) do
    "#{@protocol}://#{@endpoint}#{url}"
  end
end