defmodule Exexec.MixProject do
  use Mix.Project

  @source_url "https://github.com/ericentin/exexec"
  @version "0.2.0"

  def project do
    [
      app: :exexec,
      version: @version,
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      docs: [
        main: "readme",
        extras: ["README.md"],
        source_url: @source_url,
        source_ref: "v#{@version}"
      ],
      deps: deps(),
      description: description(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:erlexec, "~> 1.10"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp description do
    "An idiomatic Elixir wrapper for erlexec."
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Eric Entin"],
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => @source_url
      }
    ]
  end
end
