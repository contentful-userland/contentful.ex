defmodule Contentful.Delivery.TaxonomyConcepts do
  @moduledoc """
  TaxonomyConcepts allows for querying the taxonomy concepts of a space via `Contentful.Query`.
  """

  alias Contentful.{TaxonomyConcept, Queryable}

  @behaviour Queryable

  @endpoint "/taxonomy/concepts"

  @impl Queryable
  def endpoint do
    @endpoint
  end

  @impl Queryable
  def resolve_collection_response(%{"items" => items}) do
    concepts =
      items
      |> Enum.map(&resolve_entity_response/1)
      |> Enum.map(fn {:ok, concept} -> concept end)

    {:ok, concepts}
  end

  @impl Queryable
  def resolve_entity_response(%{
        "sys" => sys,
        "uri" => uri,
        "prefLabel" => pref_label,
        "altLabels" => alt_labels,
        "hiddenLabels" => hidden_labels,
        "notations" => notations,
        "note" => note,
        "changeNote" => change_note,
        "definition" => definition,
        "editorialNote" => editorial_note,
        "historyNote" => history_note,
        "scopeNote" => scope_note,
        "example" => example,
        "broader" => broader,
        "related" => related,
        "conceptSchemes" => concept_schemes
      }) do
    {:ok,
     %TaxonomyConcept{
       sys: sys,
       uri: uri,
       pref_label: pref_label,
       alt_labels: alt_labels,
       hidden_labels: hidden_labels,
       notations: notations,
       note: note,
       change_note: change_note,
       definition: definition,
       editorial_note: editorial_note,
       history_note: history_note,
       scope_note: scope_note,
       example: example,
       broader: broader,
       related: related,
       concept_schemes: concept_schemes
     }}
  end
end
