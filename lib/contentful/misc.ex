defmodule Contentful.Misc do
  @moduledoc """
  Provides some functions that fit nowhere else and can be shared freely.
  """

  @doc """
  provides a generic fallback method in case a returned value is `nil`.

  Inspired by [@expede](https://github.com/expede) and her talk at Code BEAM V 2020.

  Usable in conjunction with other getters to enable function chains:

  ## Example

      1 = [a: 1, b: 2, c: 3] |> Keyword.get(:a)
      4 = [a: 1, b: 2, c: 3] |> Keyword.get(:d) |> fallback(4)
  """
  @spec fallback(nil, any()) :: any()
  def fallback(nil, value) do
    value
  end

  def fallback(value, _) do
    value
  end
end
