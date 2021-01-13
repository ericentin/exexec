# Exexec

[![Build Status](https://travis-ci.org/ericentin/exexec.svg?branch=master)](https://travis-ci.org/ericentin/exexec)
[![Hex.pm package version](https://img.shields.io/hexpm/v/exexec.svg)](https://hex.pm/packages/exexec)
[![Hexdocs.pm](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/exexec/)
[![Hex.pm package license](https://img.shields.io/hexpm/l/exexec.svg)](https://github.com/ericentin/exexec/blob/master/LICENSE)
[![Hex.pm package download](https://img.shields.io/hexpm/dt/exexec.svg)](https://hex.pm/packages/exexec)
[![Last Updated](https://img.shields.io/github/last-commit/ericentin/exexec.svg)](https://github.com/ericentin/exexec/commits/master)

Execute and control OS processes from Elixir.

An idiomatic Elixir wrapper for Serge Aleynikov's excellent
[erlexec](https://github.com/saleyn/erlexec), Exexec provides an Elixir
interface as well as some nice Elixir-y goodies on top.

## Installation

The package can be installed by adding `:exexec` to your list of dependencies
in `mix.exs`:

```elixir
def deps do
  [
    {:exexec, "~> 0.2"}
  ]
end
```

## License

Copyright (c) 2016 Eric Entin

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
