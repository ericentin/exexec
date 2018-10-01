defmodule Exexec.Mixfile do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :exexec,
      version: @version,
      elixir: "~> 1.2",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      dialyzer: [
        plt_add_deps: :project,
        plt_add_apps: [:erlexec],
      ],
      source_url: "https://github.com/antipax/exexec",
      docs: [
        main: "Exexec",
        extras: ["README.md"],
        source_ref: "v#{@version}"
      ],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test],
    ]
  end

  def application do
    [included_applications: [:erlexec]]
  end

  defp deps do
    [
      {:erlexec, "~> 1.7"},
      {:dialyxir, "~> 0.3", only: [:dev, :test]},
      {:ex_doc, "~> 0.11", only: :dev},
      {:excoveralls, "~> 0.6.2", only: :test},
      {:inch_ex, ">= 0.0.0", only: :docs}
    ]
  end

  defp description do
    "An idiomatic Elixir wrapper for erlexec."
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Eric Entin"],
      licenses: ["Apache 2.0"],
      links: %{
        "GitHub" => "https://github.com/antipax/exexec"
      }
    ]
  end
end
