# Exexec

Execute and control OS processes from Elixir.

An idiomatic Elixir wrapper for Serge Aleynikov's excellent
[erlexec](https://github.com/saleyn/erlexec), Exexec, provides an Elixir
interface as well as some nice Elixir-y goodies on top.

## Installation

  1. Add exexec to your list of dependencies in `mix.exs`:

        def deps do
          [{:exexec, "~> 1.0.0"}]
        end

  2. Ensure exexec is started before your application:

        def application do
          [applications: [:exexec]]
        end
