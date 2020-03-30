defmodule Contentful do
  @moduledoc """
  The Contentful SDK provides helper functions and structs for the available
  Contentful API implementations and serves as a container
  for the shared structs.

  The available Contentful APIs are:
    * [Content Delivery API (CDA)](https://www.contentful.com/developers/docs/references/content-delivery-api/) - for accessing production ready content
    * [Content Preview API (CPA)](https://www.contentful.com/developers/docs/references/content-preview-api/) - for accessing drafts prepublication
    * [Content Management API (CMA)](https://www.contentful.com/developers/docs/references/content-management-api/) - for managing your content


  ## Setup

  In order to add the Contentful SDK add the following to your `mix.exs`:

  ```
  # mix.exs

  def deps do
    [
      # your other dependencies
      {:contentful, "~> 0.1"}
    ]
  end
  ```

  You can configure your access token(s) and Contentful environments via your local
  config.exs:

  ```
  # in config.exs
  config :contentful, json_library: Poison # optional Jason is the default

  # per API definition:

  config :contentful, delivery: [
    access_token: "<YOU CDA token>",
    environment: "my-environment" # default is `master`
  ]

  config :contentful, management: [
    coming: :soon
  ]

  config :contentful, preview: [
    coming: :soon
  ]
  ```
  Please note that the default `json_library` that this SDK is tested with is `Jason`, yet `Poison` should be compatible.
  """

  @doc """
  The JSON library to use. Can be either configured to `Jason` or `Poison`.

  ## Examples

      # in config/config.exs
      config :contentful, json_library: Jason

      iex> Contentful.json_library()
      Jason

  """
  @spec json_library(atom()) :: module()
  def json_library() do
    case Application.get_env(:contentful, :json_library) do
      nil -> Jason
      lib -> lib
    end
  end
end
