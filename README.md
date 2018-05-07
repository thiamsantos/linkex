# Linkex

[![Travis](https://img.shields.io/travis/thiamsantos/linkex.svg)](https://travis-ci.org/thiamsantos/linkex)
[![Hex.pm](https://img.shields.io/hexpm/v/linkex.svg)](https://hex.pm/packages/linkex)
[![Docs](https://img.shields.io/badge/hex-docs-green.svg)](https://hexdocs.pm/linkex)

> Encode and decode HTTP Link headers.

## Table of Contents

- [Install](#install)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)


## Install

The package can be installed by adding `linkex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:linkex, "~> 0.1.0"}
  ]
end
```

## Usage

```elixir
iex> Linkex.encode("<https://api.github.com/user/13632762/repos?client_id=1&client_secret=2&page=2&per_page=100>; rel="next", <https://api.github.com/user/13632762/repos?client_id=1&client_secret=2&page=3&per_page=100>; rel="last")
{:ok, %LinkHeader{
  last: %Entry{
    target:
      %URI{
        authority: "api.github.com",
        fragment: nil,
        host: "api.github.com",
        path: "/user/13632762/repos",
        port: 443,
        query: "client_id=1&client_secret=2&page=3&per_page=100",
        scheme: "https",
        userinfo: nil
      }
  },
  next: %Entry{
    target:
      %URI{
        authority: "api.github.com",
        fragment: nil,
        host: "api.github.com",
        path: "/user/13632762/repos",
        port: 443,
        query: "client_id=1&client_secret=2&page=2&per_page=100",
        scheme: "https",
        userinfo: nil
      }
  }
}}

iex> Linkex.decode(%LinkHeader{
  last: %Entry{
    target:
      %URI{
        authority: "api.github.com",
        fragment: nil,
        host: "api.github.com",
        path: "/user/13632762/repos",
        port: 443,
        query: "client_id=1&client_secret=2&page=3&per_page=100",
        scheme: "https",
        userinfo: nil
      }
  },
  next: %Entry{
    target:
      %URI{
        authority: "api.github.com",
        fragment: nil,
        host: "api.github.com",
        path: "/user/13632762/repos",
        port: 443,
        query: "client_id=1&client_secret=2&page=2&per_page=100",
        scheme: "https",
        userinfo: nil
      }
  }
})

{:ok, "<https://api.github.com/user/13632762/repos?client_id=1&client_secret=2&page=2&per_page=100>; rel="next", <https://api.github.com/user/13632762/repos?client_id=1&client_secret=2&page=3&per_page=100>; rel="last"}
```

## Contributing

See the [contributing file](CONTRIBUTING.md).

## License

[Apache License, Version 2.0](LICENSE) © [Thiago Santos](https://github.com/thiamsantos)
