defmodule Linkex.LinkHeader do
  defstruct alternate: nil,
            appendix: nil,
            bookmark: nil,
            chapter: nil,
            contents: nil,
            copyright: nil,
            current: nil,
            describedby: nil,
            edit: nil,
            edit_media: nil,
            enclosure: nil,
            first: nil,
            glossary: nil,
            help: nil,
            hub: nil,
            index: nil,
            last: nil,
            latest_version: nil,
            license: nil,
            next_archive: nil,
            next: nil,
            payment: nil,
            predecessor_version: nil,
            prev_archive: nil,
            prev: nil,
            previous: nil,
            related: nil,
            replies: nil,
            section: nil,
            self: nil,
            service: nil,
            start: nil,
            stylesheet: nil,
            subsection: nil,
            successor_version: nil,
            up: nil,
            version_history: nil,
            via: nil,
            working_copy: nil,
            working_copy_of: nil

  def valid_relations do
    %__MODULE__{}
    |> Map.from_struct()
    |> Map.keys()
    |> Enum.map(fn key -> Atom.to_string(key) end)
  end
end
