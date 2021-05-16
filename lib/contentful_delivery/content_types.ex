defmodule Contentful.Delivery.ContentTypes do
  @moduledoc """
  Provides functions around reading content types from a given `Contentful.Space`

  See https://www.contentful.com/developers/docs/references/content-delivery-api/#/reference/content-types/content-type

  ## Simple calls

  Fetching a single content type is straight forward:

      import Contentful.Query
      alias Contentful.ContentType
      alias Contentful.Delivery.ContentTypes

      {:ok, %ContentType{id: "my_content_type_id"}} = ContentTypes |> fetch_one("my_content_type_id")

  Fetching multiple content types is also possible:

      import Contentful.Query
      alias Contentful.ContentType
      alias Contentful.Delivery.ContentTypes

      {:ok, [%ContentType{id: "my_content_type_id"} | _ ]} = ContentTypes |> fetch_all

  ## Accessing common resource attributes

  A `Contentful.ContentType` embeds `Contentful.SysData` with extra information about the entry:

      import Contentful.Query
      alias Contentful.ContentType
      alias Contentful.Delivery.ContentTypes

      {:ok, content_type} = ContentTypes |> fetch_one("my_content_type_id")

      "my_content_type_id" = content_type.id
      "<a timestamp for updated_at>" = content_type.sys.updated_at
      "<a timestamp for created_at>" = content_type.sys.created_at

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
       id: id,
       name: name,
       description: description,
       display_field: display_field,
       fields: Enum.map(fields, &build_field/1),
       sys: %SysData{revision: rev, updated_at: updated_at, created_at: created_at}
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
