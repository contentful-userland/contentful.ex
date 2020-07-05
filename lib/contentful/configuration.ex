defmodule Contentful.Configuration do
  @moduledoc """
  Provides Configuration for the different Contentful modules, providing easier access to the values
  in config/*.exs
  """

  def get(key, context \\ :delivery) do
    context |> config() |> Keyword.get(key)
  end

  defp config(context) do
    Application.get_env(:contentful, context, [])
  end
end
