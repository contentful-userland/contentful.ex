defmodule Contentful.Delivery.TaxonomyConceptSchemes do
  @moduledoc """
  TaxonomyConceptSchemes allows for querying the taxonomy concept schemes of a space via `Contentful.Query`.
  """

  alias Contentful.{TaxonomyConceptScheme, Queryable}

  @behaviour Queryable

  @endpoint "/taxonomy/concept-schemes"

  @impl Queryable
  def endpoint do
    @endpoint
  end

  @impl Queryable
  def resolve_collection_response(%{"items" => items}) do
    schemes =
      items
      |> Enum.map(&resolve_entity_response/1)
      |> Enum.map(fn {:ok, scheme} -> scheme end)

    {:ok, schemes}
  end

  @impl Queryable
  def resolve_entity_response(%{
        "sys" => sys,
        "uri" => uri,
        "prefLabel" => pref_label,
        "definition" => definition,
        "concepts" => concepts,
        "topConcepts" => top_concepts,
        "totalConcepts" => total_concepts
      }) do
    {:ok,
     %TaxonomyConceptScheme{
       sys: sys,
       uri: uri,
       pref_label: pref_label,
       definition: definition,
       concepts: concepts,
       top_concepts: top_concepts,
       total_concepts: total_concepts
     }}
  end
end
