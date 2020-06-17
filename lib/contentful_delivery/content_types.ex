defmodule Contentful.Delivery.ContentTypes do
  @moduledoc """
  Provides functions around reading content types from a given `Contentful.Space`
  """

  alias Contentful.{ContentType, Queryable, SysData}

  @behaviour Queryable

  @endpoint "/content_types"

  @impl Queryable
  def endpoint do
    @endpoint
  end

  @impl Queryable
  def resolve_collection_response(%{"items" => items, "total" => total}) do
    content_types =
      items
      |> Enum.map(&resolve_entity_response/1)
      |> Enum.map(fn {:ok, ct} -> ct end)

    {:ok, content_types, total: total}
  end

  @impl Queryable
  def resolve_entity_response(%{
        "name" => name,
        "description" => description,
        "displayField" => display_field,
        "sys" => %{
          "id" => id,
          "revision" => rev,
          "updatedAt" => updated_at,
          "createdAt" => created_at
        },
        "fields" => fields
      }) do
    {:ok,
     %ContentType{
       name: name,
       description: description,
       display_field: display_field,
       fields: Enum.map(fields, &build_field/1),
       sys: %SysData{id: id, revision: rev, updated_at: updated_at, created_at: created_at}
     }}
  end

  defp build_field(%{
         "required" => req,
         "name" => name,
         "localized" => loc,
         "disabled" => disabled,
         "omitted" => omit,
         "type" => type
       }) do
    %ContentType.Field{
      required: req,
      name: name,
      localized: loc,
      disabled: disabled,
      omitted: omit,
      type: type,
      validations: []
    }
  end
end
