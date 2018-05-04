defmodule Linkex.Entry do
  defstruct target: nil,
            anchor: nil,
            rev: nil,
            hreflang: nil,
            media: nil,
            title: nil,
            type: nil,
            extension: %{}

  def valid_values do
    %__MODULE__{}
    |> Map.from_struct()
    |> Map.keys()
    |> List.delete(:extension)
    |> Enum.map(fn key -> Atom.to_string(key) end)
  end
end
