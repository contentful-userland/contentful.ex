defmodule Contentful.Entry.AssetResolver do
  @moduledoc """
  The module provides functions to resolve the Entry <-> Asset relationships.
  """

  alias Contentful.Entry

  @doc """
  extracts asset ids nested in the fields of a single entry
  """
  @spec find_linked_asset_ids(Entry.t()) :: list(String.t())
  def find_linked_asset_ids(%Entry{fields: fields}) do
    fields |> Enum.reduce([], &find_in_data/2)
  end

  defp find_in_data(
         {_field_name, %{"sys" => %{"id" => id, "linkType" => "Asset", "type" => "Link"}}},
         acc
       ) do
    [id | acc]
  end

  defp find_in_data(
         {_field_name, map},
         acc
       )
       when is_map(map) do
    map |> Enum.reduce(acc, &find_in_data/2)
  end

  defp find_in_data({_field_name, []}, acc) do
    acc
  end

  defp find_in_data(
         {_field_name, list},
         acc
       )
       when is_list(list) do
    list |> Enum.flat_map(fn fields -> fields |> Enum.reduce(acc, &find_in_data/2) end)
  end

  defp find_in_data({_field_name, _value}, acc), do: acc
end
