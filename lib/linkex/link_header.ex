defmodule Linkex.LinkHeader do
  @moduledoc """
  Link Header struct.
  """
  alias Linkex.Entry

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

  @type t :: %__MODULE__{
          alternate: Entry.t(),
          appendix: Entry.t(),
          bookmark: Entry.t(),
          chapter: Entry.t(),
          contents: Entry.t(),
          copyright: Entry.t(),
          current: Entry.t(),
          describedby: Entry.t(),
          edit: Entry.t(),
          edit_media: Entry.t(),
          enclosure: Entry.t(),
          first: Entry.t(),
          glossary: Entry.t(),
          help: Entry.t(),
          hub: Entry.t(),
          index: Entry.t(),
          last: Entry.t(),
          latest_version: Entry.t(),
          license: Entry.t(),
          next_archive: Entry.t(),
          next: Entry.t(),
          payment: Entry.t(),
          predecessor_version: Entry.t(),
          prev_archive: Entry.t(),
          prev: Entry.t(),
          previous: Entry.t(),
          related: Entry.t(),
          replies: Entry.t(),
          section: Entry.t(),
          self: Entry.t(),
          service: Entry.t(),
          start: Entry.t(),
          stylesheet: Entry.t(),
          subsection: Entry.t(),
          successor_version: Entry.t(),
          up: Entry.t(),
          version_history: Entry.t(),
          via: Entry.t(),
          working_copy: Entry.t(),
          working_copy_of: Entry.t()
        }

  def valid_relations do
    %__MODULE__{}
    |> Map.from_struct()
    |> Map.keys()
    |> Enum.map(fn key -> Atom.to_string(key) end)
  end
end
