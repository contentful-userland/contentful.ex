defmodule Contentful.TaxonomyConceptScheme do
  alias Contentful.TaxonomyConcept

  defstruct [
    :sys,
    :uri,
    :pref_label,
    :definition,
    :concepts,
    :top_concepts,
    :total_concepts
  ]

  @type t :: %Contentful.TaxonomyConceptScheme{
          sys: %Contentful.SysData{},
          uri: String.t(),
          pref_label: map(),
          definition: map(),
          concepts: list(TaxonomyConcept.t()),
          top_concepts: list(TaxonomyConcept.t()),
          total_concepts: integer()
        }
end
