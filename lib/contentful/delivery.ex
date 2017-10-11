defmodule Contentful.Delivery do
  @moduledoc """
  A HTTP client for Contentful.
  This module contains the functions to interact with Contentful's read-only
  Content Delivery API.
  """


  use Contentful.Functions
  #@behaviour Contentful.Functions

  @endpoint "cdn.contentful.com"
  @protocol "https"

  defp process_url(url) do
    "#{@protocol}://#{@endpoint}#{url}"
  end
end
