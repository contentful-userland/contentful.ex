defmodule Contentful.Delivery.Spaces do
  @moduledoc """
  Spaces provides function related to the reading of spaces
  through the Contentful Delivery API
  """

  alias Contentful.{Queryable, Space, SysData}

  @endpoint "/spaces"

  @behaviour Queryable

  @impl Queryable
  def endpoint do
    @endpoint
  end

  @impl Queryable
  def resolve_collection_response(_) do
    {:error, [message: "Fetching multiple spaces is not supported"], total: 0}
  end

  @impl Queryable
  def resolve_entity_response(%{
        "locales" => _locales,
        "name" => name,
        "sys" => %{"id" => id, "type" => "Space"}
      }) do
    {:ok, %Space{name: name, sys: %SysData{id: id}}}
  end
end
