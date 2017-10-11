defmodule Contentful.Preview do
  @moduledoc """
  A HTTP client for Contentful Preview Endpoint.
  This module connects to the preview.contentful.com endpoint and requires the preview access token
  """

  use Contentful.Functions
  @behaviour Contentful.Functions

  @endpoint "preview.contentful.com"
  @protocol "https"

  def process_url(url), do: "#{@protocol}://#{@endpoint}#{url}"
end