defmodule Linkex.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :linkex,
      version: @version,
      elixir: "~> 1.4",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs(),
      name: "Linkex",
      source_url: "https://github.com/thiamsantos/linkex"
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    """
    Encode and decode HTTP Link headers.
    """
  end

  defp deps do
    [
      {:ex_doc, "~> 0.16", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["Thiago Santos"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/thiamsantos/linkex"}
    ]
  end

  defp docs do
    [
      main: "readme",
      name: "Linkex",
      source_ref: "v#{@version}",
      canonical: "http://hexdocs.pm/linkex",
      source_url: "https://github.com/thiamsantos/linkex",
      extras: [
        "README.md",
        "CONTRIBUTING.md"
      ]
    ]
  end
end
