defmodule Contentful.Delivery.Entries do
  @moduledoc """
  Entries allows for querying the entries of a space via `Contentful.Query`.

  ## Fetching a single entry

      import Contentful.Query
      alias Contentful.Delivery.Entries

      {:ok, entry} = Entries |> fetch_one("my_entry_id")

  ## Simple querying of a collection of entries

      import Contentful.Query
      alias Contentful.Delivery.Entries

      # fetches the entries based on the `space_id`, `environment` and `access_token` in config/config.exs
      {:ok, entries, total: _total_count_of_entries} =
        Entries |> fetch_all

      # fetches the entries by passing  `space_id`, `environment` and `access_token`
      space_id = "<my_space_id>"
      environment = "<my_environment>"
      access_token = "<my_access_token>"

      {:ok, entries, total: _total_count_of_entries} =
        Entries |> fetch_all(space_id, environment, access_token)

  ## More advanced query with included links

  Entries can have links included, which limits the amount of times a client has to request data from the server:

      import Contentful.Query
      alias Contentful.{Asset, Entry}
      alias Contentful.Delivery.Entries

      # The default include depth is 1 (max 10)
      {:ok, [ %Entry{} = entry | _ ], total: _total_count_of_entries} =
        Entries |> include |> fetch_all

      # any links within entry.fields will have been replaced with actual entities (e.g. an %Asset{] or %Entry{} struct)

  ## Accessing common resource attributes

  Entries embed `Contentful.SysData` with extra information about the entry:

    import Contentful.Query
    alias Contentful.{ContentType, Entry, SysData}
    alias Contentful.Delivery.Entries

    {:ok, entry} = Entries |> fetch_one("my_entry_id")

    "my_entry_id" = entry.id
    "<a timestamp for updated_at>" = entry.sys.updated_at
    "<a timestamp for created_at>" = entry.sys.created_at
    "<a locale string>" = entry.sys.locale
    %ContentType{id: "the_associated_content_type_id"} =  entry.sys.content_type

  """

  alias Contentful.{ContentType, Entry, Queryable, SysData}
  alias Contentful.Entry.LinkResolver

  @behaviour Queryable

  @endpoint "/entries"

  @impl Queryable
  def endpoint do
    @endpoint
  end

  @doc """
  specifies the collection resolver for the case when links are included within the entries response
  """
  def resolve_collection_response(%{
        "total" => total,
        "items" => items,
        "includes" => includes
      })
      when includes != %{} do
    {:ok, entries, total: total} =
      resolve_collection_response(%{"total" => total, "items" => items})

    {:ok,
     entries
     |> Enum.map(fn entry -> entry |> LinkResolver.replace_links_with_entities(includes) end),
     total: total}
  end

  @doc """
  maps a standard API response for queries compliant with the `Contentful.Queryable` behaviour.


  """
  @impl Queryable
  def resolve_collection_response(%{"total" => total, "items" => items}) do
    entries =
      items
      |> Enum.map(&resolve_entity_response/1)
      |> Enum.map(fn {:ok, entry} -> entry end)

    {:ok, entries, total: total}
  end

  @impl Queryable
  @doc """

  maps a standard API response for a single entry returned, compliant with the `Contentful.Queryable` behaviour.
  """
  def resolve_entity_response(%{
        "fields" => fields,
        "sys" => %{
          "id" => id,
          "revision" => rev,
          "updatedAt" => updated_at,
          "createdAt" => created_at,
          "locale" => locale,
          "contentType" => %{"sys" => %{"id" => content_type_id}}
        }
      }) do
    {:ok,
     %Entry{
       fields: fields,
       sys: %SysData{
         id: id,
         revision: rev,
         locale: locale,
         updated_at: updated_at,
         created_at: created_at,
         content_type: %ContentType{id: content_type_id}
       }
     }}
  end
end
