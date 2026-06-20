defmodule Contentful.Metadata do
  defstruct [
    :concepts,
    :tags
  ]

  @type t :: %Contentful.Metadata{
          concepts: list(%Contentful.TaxonomyConcept{}),
          tags: list(%Contentful.Tag{})
        }
end
