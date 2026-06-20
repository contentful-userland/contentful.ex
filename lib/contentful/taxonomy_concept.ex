defmodule Contentful.TaxonomyConcept do
  alias Contentful.TaxonomyConceptScheme

  defstruct [
    :sys,
    :uri,
    :pref_label,
    :alt_labels,
    :hidden_labels,
    :notations,
    :note,
    :change_note,
    :definition,
    :editorial_note,
    :history_note,
    :scope_note,
    :example,
    :broader,
    :related,
    :concept_schemes
  ]

  @type t :: %Contentful.TaxonomyConcept{
          sys: %Contentful.SysData{},
          uri: String.t(),
          pref_label: map(),
          alt_labels: [map()],
          hidden_labels: [map()],
          notations: list(),
          note: map(),
          change_note: map(),
          definition: map(),
          editorial_note: map(),
          history_note: map(),
          scope_note: map(),
          example: map(),
          broader: list(__MODULE__.t()),
          related: list(__MODULE__.t()),
          concept_schemes: list(TaxonomyConceptScheme.t())
        }
end
