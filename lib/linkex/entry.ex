defmodule Linkex.Entry do
  @moduledoc """
  Relation type entry.
  """

  defstruct target: nil,
            anchor: nil,
            rev: nil,
            hreflang: nil,
            media: nil,
            title: nil,
            type: nil,
            extension: %{}

  @type t :: %__MODULE__{
          target: URI.t(),
          anchor: URI.t(),
          rev: String.t(),
          hreflang: String.t(),
          media: String.t(),
          title: String.t(),
          type: String.t(),
          extension: map()
        }

  def valid_values do
    %__MODULE__{}
    |> Map.from_struct()
    |> Map.keys()
    |> List.delete(:extension)
    |> Enum.map(fn key -> Atom.to_string(key) end)
  end
end
