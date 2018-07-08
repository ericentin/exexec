[![Build Status](https://travis-ci.org/antipax/exexec.svg?branch=master)](https://travis-ci.org/antipax/exexec) [![Coverage Status](https://coveralls.io/repos/github/antipax/exexec/badge.svg?branch=master)](https://coveralls.io/github/antipax/exexec?branch=master) [![Inline docs](http://inch-ci.org/github/antipax/exexec.svg?branch=master)](http://inch-ci.org/github/antipax/exexec) [![Hex.pm package version](https://img.shields.io/hexpm/v/exexec.svg)](https://hex.pm/packages/exexec) [![Hex.pm package license](https://img.shields.io/hexpm/l/exexec.svg)](https://github.com/antipax/exexec/blob/master/LICENSE)

# Exexec

Execute and control OS processes from Elixir.

An idiomatic Elixir wrapper for Serge Aleynikov's excellent
[erlexec](https://github.com/saleyn/erlexec), Exexec provides an Elixir
interface as well as some nice Elixir-y goodies on top.

## Installation

Add exexec to your list of dependencies in `mix.exs`:
```
  def deps do
    [{:exexec, "~> 0.2"}]
  end
```

**NOTE:** version `0.2` is compatible with OTP 21 and upwards. Use `0.1` for earlier OTP versions.
