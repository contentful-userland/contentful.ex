defmodule Contentful.Delivery do
  @moduledoc """
  Documentation for `Contentful.Delivery`.
  """

  @doc """
  Gets the json library for the Contetnful Delivery API based 
  on the config/config.exs. Will override the central configuration
  option if set.


  ## Examples

      # in config/config.exs
      config :contentful, json_library: Jason
      config :contentful, json_library: Poison

      The fallback is Jason, in case no option is set.


      iex> Contentful.Delivery.json_library()
      Poison

  """
  @spec json_library :: module()
  def json_library do
    Contentful.json_library(:contentful_delivery)
  end
end
