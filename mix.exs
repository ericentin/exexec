defmodule Exexec.Mixfile do
  use Mix.Project

  def project do
    [app: :exexec,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [included_applications: [:erlexec]]
  end

  defp deps do
    [
      {:erlexec, "~> 1.1.2"},
      {:ex_doc, "~> 0.11.1", only: [:dev, :test]},
    ]
  end
end
