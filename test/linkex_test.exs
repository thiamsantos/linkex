defmodule LinkexTest do
  use ExUnit.Case, async: true

  alias Linkex.{LinkHeader, Entry, DecodeError, EncodeError}

  describe "decode/1" do
    test "a proper link header with next and last" do
      link =
        ~s(<https://api.github.com/user/13632762/repos?client_id=1&client_secret=2&page=2&per_page=100>; rel="next", ) <>
          ~s(<https://api.github.com/user/13632762/repos?client_id=1&client_secret=2&page=3&per_page=100>; rel="last")

      {:ok, actual} = Linkex.decode(link)

      expected = %LinkHeader{
        last: %Entry{
          target:
            URI.parse(
              "https://api.github.com/user/13632762/repos?client_id=1&client_secret=2&page=3&per_page=100"
            )
        },
        next: %Entry{
          target:
            URI.parse(
              "https://api.github.com/user/13632762/repos?client_id=1&client_secret=2&page=2&per_page=100"
            )
        }
      }

      assert actual == expected
    end

    test "unquoted relationships" do
      link =
        ~s(<https://api.github.com/user/13632762/repos?client_id=1&client_secret=2&page=2&per_page=100>; rel=next, ) <>
          ~s(<https://api.github.com/user/13632762/repos?client_id=1&client_secret=2&page=3&per_page=100>; rel=last)

      {:ok, actual} = Linkex.decode(link)

      expected = %LinkHeader{
        next: %Entry{
          target:
            URI.parse(
              "https://api.github.com/user/13632762/repos?client_id=1&client_secret=2&page=2&per_page=100"
            )
        },
        last: %Entry{
          target:
            URI.parse(
              "https://api.github.com/user/13632762/repos?client_id=1&client_secret=2&page=3&per_page=100"
            )
        }
      }

      assert actual == expected
    end

    test "a proper link header with next, prev and last" do
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

    test "an empty link header" do
      {:ok, actual} = Linkex.decode("")
      expected = %LinkHeader{}

      assert actual == expected
    end

    test "a proper link header with next and a link without rel" do
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

    test "a proper link header with next and properties besides rel" do
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

    test "a proper link header with a comma in the url" do
      link = ~s(<https://imaginary.url.notreal/?name=What,+me+worry>; rel="next";)

      {:ok, actual} = Linkex.decode(link)

      expected = %LinkHeader{
        next: %Entry{
          target: URI.parse("https://imaginary.url.notreal/?name=What,+me+worry")
        }
      }

      assert actual == expected
    end

    test "a proper link header with matrix parameters" do
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

    test "a proper link header with a multi-word rel" do
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
              "https://api.github.com/user/13632762/repos?client_id=1&client_secret=2&page=3&per_page=100"
            )
        },
        next: %Entry{
          target:
            URI.parse(
              "https://api.github.com/user/13632762/repos?client_id=1&client_secret=2&page=2&per_page=100"
            )
        }
      }

      assert actual == expected
    end

    test "all relational types defined on rfc 5988" do
      link =
        ~s(<https://example.com/alternate>; rel="alternate", ) <>
          ~s(<https://example.com/appendix>; rel="appendix", ) <>
          ~s(<https://example.com/bookmark>; rel="bookmark", ) <>
          ~s(<https://example.com/chapter>; rel="chapter", ) <>
          ~s(<https://example.com/contents>; rel="contents", ) <>
          ~s(<https://example.com/copyright>; rel="copyright", ) <>
          ~s(<https://example.com/current>; rel="current", ) <>
          ~s(<https://example.com/describedby>; rel="describedby", ) <>
          ~s(<https://example.com/edit>; rel="edit", ) <>
          ~s(<https://example.com/edit-media>; rel="edit-media", ) <>
          ~s(<https://example.com/enclosure>; rel="enclosure", ) <>
          ~s(<https://example.com/first>; rel="first", ) <>
          ~s(<https://example.com/glossary>; rel="glossary", ) <>
          ~s(<https://example.com/help>; rel="help", ) <>
          ~s(<https://example.com/hub>; rel="hub", ) <>
          ~s(<https://example.com/index>; rel="index", ) <>
          ~s(<https://example.com/last>; rel="last", ) <>
          ~s(<https://example.com/latest-version>; rel="latest-version", ) <>
          ~s(<https://example.com/license>; rel="license", ) <>
          ~s(<https://example.com/next>; rel="next", ) <>
          ~s(<https://example.com/next-archive>; rel="next-archive", ) <>
          ~s(<https://example.com/payment>; rel="payment", ) <>
          ~s(<https://example.com/prev>; rel="prev", ) <>
          ~s(<https://example.com/predecessor-version>; rel="predecessor-version", ) <>
          ~s(<https://example.com/previous>; rel="previous", ) <>
          ~s(<https://example.com/prev-archive>; rel="prev-archive", ) <>
          ~s(<https://example.com/related>; rel="related", ) <>
          ~s(<https://example.com/replies>; rel="replies", ) <>
          ~s(<https://example.com/section>; rel="section", ) <>
          ~s(<https://example.com/self>; rel="self", ) <>
          ~s(<https://example.com/service>; rel="service", ) <>
          ~s(<https://example.com/start>; rel="start", ) <>
          ~s(<https://example.com/stylesheet>; rel="stylesheet", ) <>
          ~s(<https://example.com/subsection>; rel="subsection", ) <>
          ~s(<https://example.com/successor-version>; rel="successor-version", ) <>
          ~s(<https://example.com/up>; rel="up", ) <>
          ~s(<https://example.com/version-history>; rel="version-history", ) <>
          ~s(<https://example.com/via>; rel="via", ) <>
          ~s(<https://example.com/working-copy>; rel="working-copy", ) <>
          ~s(<https://example.com/working-copy-of>; rel="working-copy-of")

      {:ok, actual} = Linkex.decode(link)

      expected = %LinkHeader{
        alternate: %Entry{
          target: URI.parse("https://example.com/alternate")
        },
        appendix: %Entry{
          target: URI.parse("https://example.com/appendix")
        },
        bookmark: %Entry{
          target: URI.parse("https://example.com/bookmark")
        },
        chapter: %Entry{
          target: URI.parse("https://example.com/chapter")
        },
        contents: %Entry{
          target: URI.parse("https://example.com/contents")
        },
        copyright: %Entry{
          target: URI.parse("https://example.com/copyright")
        },
        current: %Entry{
          target: URI.parse("https://example.com/current")
        },
        describedby: %Entry{
          target: URI.parse("https://example.com/describedby")
        },
        edit: %Entry{
          target: URI.parse("https://example.com/edit")
        },
        edit_media: %Entry{
          target: URI.parse("https://example.com/edit-media")
        },
        enclosure: %Entry{
          target: URI.parse("https://example.com/enclosure")
        },
        first: %Entry{
          target: URI.parse("https://example.com/first")
        },
        glossary: %Entry{
          target: URI.parse("https://example.com/glossary")
        },
        help: %Entry{
          target: URI.parse("https://example.com/help")
        },
        hub: %Entry{
          target: URI.parse("https://example.com/hub")
        },
        index: %Entry{
          target: URI.parse("https://example.com/index")
        },
        last: %Entry{
          target: URI.parse("https://example.com/last")
        },
        latest_version: %Entry{
          target: URI.parse("https://example.com/latest-version")
        },
        license: %Entry{
          target: URI.parse("https://example.com/license")
        },
        next: %Entry{
          target: URI.parse("https://example.com/next")
        },
        next_archive: %Entry{
          target: URI.parse("https://example.com/next-archive")
        },
        payment: %Entry{
          target: URI.parse("https://example.com/payment")
        },
        prev: %Entry{
          target: URI.parse("https://example.com/prev")
        },
        predecessor_version: %Entry{
          target: URI.parse("https://example.com/predecessor-version")
        },
        previous: %Entry{
          target: URI.parse("https://example.com/previous")
        },
        prev_archive: %Entry{
          target: URI.parse("https://example.com/prev-archive")
        },
        related: %Entry{
          target: URI.parse("https://example.com/related")
        },
        replies: %Entry{
          target: URI.parse("https://example.com/replies")
        },
        section: %Entry{
          target: URI.parse("https://example.com/section")
        },
        self: %Entry{
          target: URI.parse("https://example.com/self")
        },
        service: %Entry{
          target: URI.parse("https://example.com/service")
        },
        start: %Entry{
          target: URI.parse("https://example.com/start")
        },
        stylesheet: %Entry{
          target: URI.parse("https://example.com/stylesheet")
        },
        subsection: %Entry{
          target: URI.parse("https://example.com/subsection")
        },
        successor_version: %Entry{
          target: URI.parse("https://example.com/successor-version")
        },
        up: %Entry{
          target: URI.parse("https://example.com/up")
        },
        version_history: %Entry{
          target: URI.parse("https://example.com/version-history")
        },
        via: %Entry{
          target: URI.parse("https://example.com/via")
        },
        working_copy: %Entry{
          target: URI.parse("https://example.com/working-copy")
        },
        working_copy_of: %Entry{
          target: URI.parse("https://example.com/working-copy-of")
        }
      }

      assert actual == expected
    end

    test "return error when the argument is invalid" do
      {:error, actual} = Linkex.decode(nil)

      expected = %DecodeError{
        message: "Expected argument to be of type `string`"
      }

      assert actual == expected
    end

    test "raised error when the argument is invalid" do
      assert_raise DecodeError, "Expected argument to be of type `string`", fn ->
        Linkex.decode!(nil)
      end
    end
  end

  describe "encode/1" do
    test "proper link header with next and last" do
      header = %LinkHeader{
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

      {:ok, actual} = Linkex.encode(header)

      expected =
        ~s(<https://api.github.com/user/13632762/repos?client_id=1&client_secret=2&page=2&per_page=100>; rel="last", ) <>
          ~s(<https://api.github.com/user/13632762/repos?client_id=1&client_secret=2&page=3&per_page=100>; rel="next")

      assert actual == expected
    end

    test "a proper link header with next, prev and last" do
      header = %LinkHeader{
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

      {:ok, actual} = Linkex.encode(header)

      expected =
        ~s(<https://api.github.com/user/13632762/repos?page=5&per_page=100>; rel="last", ) <>
          ~s(<https://api.github.com/user/13632762/repos?page=3&per_page=100>; rel="next", ) <>
          ~s(<https://api.github.com/user/13632762/repos?page=1&per_page=100>; rel="prev")

      assert actual == expected
    end

    test "an empty link header" do
      {:ok, actual} = Linkex.encode(%LinkHeader{})
      expected = ""

      assert actual == expected
    end

    test "a proper link header with next and properties besides rel" do
      header = %LinkHeader{
        next: %Entry{
          target: URI.parse("https://api.github.com/user/13632762/repos?page=3&per_page=100"),
          extension: %{
            "hello" => "world",
            "pet" => "cat"
          }
        }
      }

      expected =
        ~s(<https://api.github.com/user/13632762/repos?page=3&per_page=100>; rel="next"; hello="world"; pet="cat")

      {:ok, actual} = Linkex.encode(header)

      assert actual == expected
    end

    test "a proper link header with a comma in the url" do
      header = %LinkHeader{
        next: %Entry{
          target: URI.parse("https://imaginary.url.notreal/?name=What,+me+worry")
        }
      }

      {:ok, actual} = Linkex.encode(header)

      expected = ~s(<https://imaginary.url.notreal/?name=What,+me+worry>; rel="next")

      assert actual == expected
    end

    test "a proper link header with matrix parameters" do
      header = %LinkHeader{
        next: %Entry{
          target:
            URI.parse(
              "https://imaginary.url.notreal/segment;foo=bar;baz/item?name=What,+me+worry"
            )
        }
      }

      {:ok, actual} = Linkex.encode(header)

      expected =
        ~s(<https://imaginary.url.notreal/segment;foo=bar;baz/item?name=What,+me+worry>; rel="next")

      assert actual == expected
    end

    test "a proper link header with a multi-word rel" do
      header = %LinkHeader{
        next: %Entry{
          target: URI.parse("https://imaginary.url.notreal/?name=What,+me+worry")
        },
        last: %Entry{
          target: URI.parse("https://imaginary.url.notreal/?name=What,+me+worry")
        }
      }

      {:ok, actual} = Linkex.encode(header)

      expected =
        ~s(<https://imaginary.url.notreal/?name=What,+me+worry>; rel="last", ) <>
          ~s(<https://imaginary.url.notreal/?name=What,+me+worry>; rel="next")

      assert actual == expected
    end

    test "all relational types defined on rfc 5988" do
      header = %LinkHeader{
        alternate: %Entry{
          target: URI.parse("https://example.com/alternate")
        },
        appendix: %Entry{
          target: URI.parse("https://example.com/appendix")
        },
        bookmark: %Entry{
          target: URI.parse("https://example.com/bookmark")
        },
        chapter: %Entry{
          target: URI.parse("https://example.com/chapter")
        },
        contents: %Entry{
          target: URI.parse("https://example.com/contents")
        },
        copyright: %Entry{
          target: URI.parse("https://example.com/copyright")
        },
        current: %Entry{
          target: URI.parse("https://example.com/current")
        },
        describedby: %Entry{
          target: URI.parse("https://example.com/describedby")
        },
        edit: %Entry{
          target: URI.parse("https://example.com/edit")
        },
        edit_media: %Entry{
          target: URI.parse("https://example.com/edit-media")
        },
        enclosure: %Entry{
          target: URI.parse("https://example.com/enclosure")
        },
        first: %Entry{
          target: URI.parse("https://example.com/first")
        },
        glossary: %Entry{
          target: URI.parse("https://example.com/glossary")
        },
        help: %Entry{
          target: URI.parse("https://example.com/help")
        },
        hub: %Entry{
          target: URI.parse("https://example.com/hub")
        },
        index: %Entry{
          target: URI.parse("https://example.com/index")
        },
        last: %Entry{
          target: URI.parse("https://example.com/last")
        },
        latest_version: %Entry{
          target: URI.parse("https://example.com/latest-version")
        },
        license: %Entry{
          target: URI.parse("https://example.com/license")
        },
        next: %Entry{
          target: URI.parse("https://example.com/next")
        },
        next_archive: %Entry{
          target: URI.parse("https://example.com/next-archive")
        },
        payment: %Entry{
          target: URI.parse("https://example.com/payment")
        },
        prev: %Entry{
          target: URI.parse("https://example.com/prev")
        },
        predecessor_version: %Entry{
          target: URI.parse("https://example.com/predecessor-version")
        },
        previous: %Entry{
          target: URI.parse("https://example.com/previous")
        },
        prev_archive: %Entry{
          target: URI.parse("https://example.com/prev-archive")
        },
        related: %Entry{
          target: URI.parse("https://example.com/related")
        },
        replies: %Entry{
          target: URI.parse("https://example.com/replies")
        },
        section: %Entry{
          target: URI.parse("https://example.com/section")
        },
        self: %Entry{
          target: URI.parse("https://example.com/self")
        },
        service: %Entry{
          target: URI.parse("https://example.com/service")
        },
        start: %Entry{
          target: URI.parse("https://example.com/start")
        },
        stylesheet: %Entry{
          target: URI.parse("https://example.com/stylesheet")
        },
        subsection: %Entry{
          target: URI.parse("https://example.com/subsection")
        },
        successor_version: %Entry{
          target: URI.parse("https://example.com/successor-version")
        },
        up: %Entry{
          target: URI.parse("https://example.com/up")
        },
        version_history: %Entry{
          target: URI.parse("https://example.com/version-history")
        },
        via: %Entry{
          target: URI.parse("https://example.com/via")
        },
        working_copy: %Entry{
          target: URI.parse("https://example.com/working-copy")
        },
        working_copy_of: %Entry{
          target: URI.parse("https://example.com/working-copy-of")
        }
      }

      {:ok, actual} = Linkex.encode(header)

      expected =
        ~s(<https://example.com/alternate>; rel="alternate", ) <>
          ~s(<https://example.com/appendix>; rel="appendix", ) <>
          ~s(<https://example.com/bookmark>; rel="bookmark", ) <>
          ~s(<https://example.com/chapter>; rel="chapter", ) <>
          ~s(<https://example.com/contents>; rel="contents", ) <>
          ~s(<https://example.com/copyright>; rel="copyright", ) <>
          ~s(<https://example.com/current>; rel="current", ) <>
          ~s(<https://example.com/describedby>; rel="describedby", ) <>
          ~s(<https://example.com/edit>; rel="edit", ) <>
          ~s(<https://example.com/edit-media>; rel="edit-media", ) <>
          ~s(<https://example.com/enclosure>; rel="enclosure", ) <>
          ~s(<https://example.com/first>; rel="first", ) <>
          ~s(<https://example.com/glossary>; rel="glossary", ) <>
          ~s(<https://example.com/help>; rel="help", ) <>
          ~s(<https://example.com/hub>; rel="hub", ) <>
          ~s(<https://example.com/index>; rel="index", ) <>
          ~s(<https://example.com/last>; rel="last", ) <>
          ~s(<https://example.com/latest-version>; rel="latest-version", ) <>
          ~s(<https://example.com/license>; rel="license", ) <>
          ~s(<https://example.com/next>; rel="next", ) <>
          ~s(<https://example.com/next-archive>; rel="next-archive", ) <>
          ~s(<https://example.com/payment>; rel="payment", ) <>
          ~s(<https://example.com/predecessor-version>; rel="predecessor-version", ) <>
          ~s(<https://example.com/prev>; rel="prev", ) <>
          ~s(<https://example.com/prev-archive>; rel="prev-archive", ) <>
          ~s(<https://example.com/previous>; rel="previous", ) <>
          ~s(<https://example.com/related>; rel="related", ) <>
          ~s(<https://example.com/replies>; rel="replies", ) <>
          ~s(<https://example.com/section>; rel="section", ) <>
          ~s(<https://example.com/self>; rel="self", ) <>
          ~s(<https://example.com/service>; rel="service", ) <>
          ~s(<https://example.com/start>; rel="start", ) <>
          ~s(<https://example.com/stylesheet>; rel="stylesheet", ) <>
          ~s(<https://example.com/subsection>; rel="subsection", ) <>
          ~s(<https://example.com/successor-version>; rel="successor-version", ) <>
          ~s(<https://example.com/up>; rel="up", ) <>
          ~s(<https://example.com/version-history>; rel="version-history", ) <>
          ~s(<https://example.com/via>; rel="via", ) <>
          ~s(<https://example.com/working-copy>; rel="working-copy", ) <>
          ~s(<https://example.com/working-copy-of>; rel="working-copy-of")

      assert actual == expected
    end

    test "target attributes" do
      header = %LinkHeader{
        next: %Entry{
          target: URI.parse("https://api.github.com/user/13632762/repos?page=3&per_page=100"),
          title: "some title",
          anchor: URI.parse("https://api.github.com/user/13632762/repos?page=2&per_page=100"),
          hreflang: "some lang",
          media: "some media",
          type: "some type"
        }
      }

      expected =
        ~s(<https://api.github.com/user/13632762/repos?page=3&per_page=100>; ) <>
          ~s(anchor="https://api.github.com/user/13632762/repos?page=2&per_page=100"; ) <>
          ~s(hreflang="some lang"; media="some media"; rel="next"; ) <>
          ~s(title="some title"; type="some type")

      {:ok, actual} = Linkex.encode(header)

      assert actual == expected
    end

    test "return error when the argument is invalid" do
      {:error, actual} = Linkex.encode(nil)

      expected = %EncodeError{
        message: "Expected argument to be of type `Linkex.LinkHeader`"
      }

      assert actual == expected
    end

    test "raised error when the argument is invalid" do
      assert_raise EncodeError, "Expected argument to be of type `Linkex.LinkHeader`", fn ->
        Linkex.encode!(nil)
      end
    end
  end
end
