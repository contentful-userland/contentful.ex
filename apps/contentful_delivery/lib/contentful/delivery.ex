defmodule Contentful.Delivery do
  @moduledoc """
  Documentation for `Contentful.Delivery`.
  """

  @doc """
  Gets the json library for the Contentful Delivery API based 
  on the config/config.exs. Will override the central configuration
  option if set.

  """
  @spec json_library :: module()
  def json_library do
    Contentful.json_library(:contentful_delivery)
  end
end
