defmodule Contentful.Mixfile do
  use Mix.Project

  def project do
    [app: :contentful,
     version: "0.1.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     deps: deps(),
     preferred_cli_env: [
       vcr: :test, "vcr.delete": :test, "vcr.check": :test, "vcr.show": :test
     ],
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [
      :logger,
      :httpoison
    ]]
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
      {:httpoison, "~> 0.13"},
      {:poison, "~> 3.1.0"},
      {:exvcr, "~> 0.7", only: :test},
      {:dogma, "~> 0.1", only: :dev}
    ]
  end

  defp description do
    """
    Contentful Content Delivery API SDK
    """
  end

  defp package do
    [# These are the default files included in the package
     name: :contentful,
     files: ["lib", "mix.exs", "README*", "LICENSE*"],
     maintainers: ["Contentful GmbH (David Litvak Bruno)"],
     licenses: ["MIT"],
     links: %{
       "GitHub" => "https://github.com/contentful-labs/contentful.ex"
     }
    ]
  end
end
