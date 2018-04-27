defmodule LinkexTest do
  use ExUnit.Case, async: true

  alias Linkex.{LinkHeader, Entry}

  describe "decode/1" do
    test "parsing a proper link header with next and last" do
      link =
        ~s(<https://api.github.com/user/13632762/repos?client_id=1&client_secret=2&page=2&per_page=100>; rel="next", ) <>
          ~s(<https://api.github.com/user/13632762/repos?client_id=1&client_secret=2&page=3&per_page=100>; rel="last")

      {:ok, actual} = Linkex.decode(link)

      expected = %LinkHeader{
        last: %Entry{
          target:
            URI.parse(
              "https://api.github.com/user/13632762/repos?client_id=1&client_secret=2&page=2&per_page=100"
            )
        },
        next: %Entry{
          target:
            URI.parse(
              "https://api.github.com/user/13632762/repos?client_id=1&client_secret=2&page=3&per_page=100"
            )
        }
      }

      assert actual == expected
    end

    test "handles unquoted relationships" do
      link =
        ~s(<https://api.github.com/user/13632762/repos?client_id=1&client_secret=2&page=2&per_page=100>; rel=next, ) <>
          ~s(<https://api.github.com/user/13632762/repos?client_id=1&client_secret=2&page=3&per_page=100>; rel=last)

      {:ok, actual} = Linkex.decode(link)

      expected = %LinkHeader{
        last: %Entry{
          target:
            URI.parse(
              "https://api.github.com/user/13632762/repos?client_id=1&client_secret=2&page=2&per_page=100"
            )
        },
        next: %Entry{
          target:
            URI.parse(
              "https://api.github.com/user/13632762/repos?client_id=1&client_secret=2&page=3&per_page=100"
            )
        }
      }

      assert actual == expected
    end

    test "parsing a proper link header with next, prev and last" do
      link =
        ~s(<https://api.github.com/user/13632762/repos?page=3&per_page=100>; rel="next", ) <>
          ~s(<https://api.github.com/user/13632762/repos?page=1&per_page=100>; rel="prev", ) <>
          ~s(<https://api.github.com/user/13632762/repos?page=5&per_page=100>; rel="last")

      {:ok, actual} = Linkex.decode(link)

      expected = %LinkHeader{
        next: %Entry{
          target: URI.parse("https://api.github.com/user/13632762/repos?page=3&per_page=100")
        },
        prev: %Entry{
          target: URI.parse("https://api.github.com/user/13632762/repos?page=1&per_page=100")
        },
        last: %Entry{
          target: URI.parse("https://api.github.com/user/13632762/repos?page=5&per_page=100")
        }
      }

      assert actual == expected
    end

    test "parsing an empty link header" do
      {:ok, actual} = Linkex.decode("")
      expected = %LinkHeader{}

      assert actual == expected
    end

    test "parsing a proper link header with next and a link without rel" do
      link =
        ~s(<https://api.github.com/user/13632762/repos?page=3&per_page=100>; rel="next", ) <>
          ~s(<https://api.github.com/user/13632762/repos?page=1&per_page=100>; pet="cat", )

      {:ok, actual} = Linkex.decode(link)

      expected = %LinkHeader{
        next: %Entry{
          target: URI.parse("https://api.github.com/user/13632762/repos?page=3&per_page=100")
        }
      }

      assert actual == expected
    end

    test "parsing a proper link header with next and properties besides rel" do
      link =
        ~s(<https://api.github.com/user/13632762/repos?page=3&per_page=100>; rel="next"; hello="world"; pet="cat")

      {:ok, actual} = Linkex.decode(link)

      expected = %LinkHeader{
        next: %Entry{
          target: URI.parse("https://api.github.com/user/13632762/repos?page=3&per_page=100"),
          extension: %{
            "hello" => "world",
            "pet" => "cat"
          }
        }
      }

      assert actual == expected
    end

    test "parsing a proper link header with a comma in the url" do
      link = ~s(<https://imaginary.url.notreal/?name=What,+me+worry>; rel="next";)

      {:ok, actual} = Linkex.decode(link)

      expected = %LinkHeader{
        next: %Entry{
          target: URI.parse("https://imaginary.url.notreal/?name=What,+me+worry")
        }
      }

      assert actual == expected
    end

    test "parsing a proper link header with matrix parameters" do
      link =
        ~s(<https://imaginary.url.notreal/segment;foo=bar;baz/item?name=What,+me+worry>; rel="next";)

      {:ok, actual} = Linkex.decode(link)

      expected = %LinkHeader{
        next: %Entry{
          target:
            URI.parse(
              "https://imaginary.url.notreal/segment;foo=bar;baz/item?name=What,+me+worry"
            )
        }
      }

      assert actual == expected
    end

    test "parsing a proper link header with a multi-word rel" do
      link = ~s(<https://imaginary.url.notreal/?name=What,+me+worry>; rel="next last";)

      {:ok, actual} = Linkex.decode(link)

      expected = %LinkHeader{
        next: %Entry{
          target: URI.parse("https://imaginary.url.notreal/?name=What,+me+worry")
        },
        last: %Entry{
          target: URI.parse("https://imaginary.url.notreal/?name=What,+me+worry")
        }
      }

      assert actual == expected
    end

    test "optional spaces" do
      link =
        ~s(<https://api.github.com/user/13632762/repos?client_id=1&client_secret=2&page=2&per_page=100>;rel="next",) <>
          ~s(<https://api.github.com/user/13632762/repos?client_id=1&client_secret=2&page=3&per_page=100>;rel="last")

      {:ok, actual} = Linkex.decode(link)

      expected = %LinkHeader{
        last: %Entry{
          target:
            URI.parse(
              "https://api.github.com/user/13632762/repos?client_id=1&client_secret=2&page=2&per_page=100"
            )
        },
        next: %Entry{
          target:
            URI.parse(
              "https://api.github.com/user/13632762/repos?client_id=1&client_secret=2&page=3&per_page=100"
            )
        }
      }

      assert actual == expected
    end
  end
end
