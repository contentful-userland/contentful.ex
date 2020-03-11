defmodule Contentful do
  @moduledoc """
  Contentful holds some helper functions for the available 
  Contentful API implementations
  """

  @doc """
  The JSON library to use. Can be either configured to Jason or Poison
  using the :contentful key in config.exs

  ## Examples

      # in config/config.exs
      config :contentful, json_library: Jason

      iex> Contentful.json_library(:contentful)
      Jason

  """
  @spec json_library(atom()) :: module()
  def json_library(app \\ __MODULE__) do
    case Application.get_env(app, :json_library) do
      nil -> Jason
      lib -> lib
    end
  end
end
