defmodule Contentful.Mixfile do
  use Mix.Project

  alias Contentful.{
    Asset,
    ContentType,
    Collection,
    CollectionStream,
    Delivery,
    Entry,
    Locale,
    MetaData,
    Space
  }

  alias Contentful.Delivery.{Assets, ContentTypes, Entries, Locales, Spaces}

  @version "0.2"

  def project do
    [
      app: :contentful,
      version: @version,
      elixir: "~> 1.6",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      preferred_cli_env: [
        vcr: :test,
        "vcr.delete": :test,
        "vcr.check": :test,
        "vcr.show": :test
      ],

      # Docs
      name: "Contentful SDK",
      source_url: "https://github.com/contentful-labs/contentful.ex",
      docs: [
        main: "Contentful",
        nest_modules_by_prefix: [
          Contentful,
          Contentful.Delivery
        ],
        groups_for_modules: [
          "Common Structures": [
            Asset,
            Asset.Fields,
            Collection,
            CollectionStream,
            ContentType,
            ContentType.Field,
            Entry,
            Locale,
            MetaData,
            Space
          ],
          "Delivery API": [
            Assets,
            ContentTypes,
            Delivery,
            Entries,
            Locales,
            Spaces
          ]
        ]
      ]
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:httpoison, "~> 1.6"},
      {:jason, "~> 1.1"},

      # dev / test
      {:exvcr, "~> 0.11", only: :test},
      {:dogma, "~> 0.1", only: :dev},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0.0-rc.7", only: [:dev], runtime: false},
      {:credo, "~> 1.2", only: [:dev, :test], runtime: false}
    ]
  end

  defp description do
    """
    Contentful Content Delivery API SDK
    """
  end

  defp package do
    # These are the default files included in the package
    [
      name: :contentful,
      files: [
        "lib/",
        "mix.exs",
        "README*",
        "LICENSE*"
      ],
      maintainers: [
        "David Litvak Bruno <Contentful GmbH>",
        "Florian Kraft <Contentful GmbH>"
      ],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/contentful-labs/contentful.ex",
        "Contentful" => "https://contentful.com",
        "Other SDKs" => "https://www.contentful.com/developers/docs/platforms/"
      }
    ]
  end
end
