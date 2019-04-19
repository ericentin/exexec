[![Build Status](https://travis-ci.org/ericentin/exexec.svg?branch=master)](https://travis-ci.org/ericentin/exexec) [![Hex.pm package version](https://img.shields.io/hexpm/v/exexec.svg)](https://hex.pm/packages/exexec) [![Hex.pm package license](https://img.shields.io/hexpm/l/exexec.svg)](https://github.com/ericentin/exexec/blob/master/LICENSE)

# Exexec

Execute and control OS processes from Elixir.

An idiomatic Elixir wrapper for Serge Aleynikov's excellent
[erlexec](https://github.com/saleyn/erlexec), Exexec provides an Elixir
interface as well as some nice Elixir-y goodies on top.

## Installation

The package can be installed
by adding `exexec` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:exexec, "~> 0.2"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/exexec](https://hexdocs.pm/exexec).
