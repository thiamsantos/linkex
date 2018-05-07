defmodule Linkex.Encoder do
  @moduledoc false
  alias Linkex.{LinkHeader, EncodeError}

  @spec encode(%LinkHeader{}) :: {:ok, String.t()}
  def encode(%LinkHeader{} = header) do
    encoded_header =
      header
      |> Map.from_struct()
      |> Map.to_list()
      |> Enum.filter(&has_value?/1)
      |> Enum.sort()
      |> Enum.map(&build_link/1)
      |> Enum.join(", ")

    {:ok, encoded_header}
  end

  @spec encode(any()) :: {:error, %EncodeError{}}
  def encode(_) do
    {:error, %EncodeError{message: "Expected argument to be of type `Linkex.LinkHeader`"}}
  end

  defp build_link({relation_type, entry}) do
    params = get_params(relation_type, entry)
    ~s(<#{URI.to_string(entry.target)}>; #{build_params(params)})
  end

  defp get_params(relation_type, entry) do
    entry
    |> Map.from_struct()
    |> Map.drop([:target, :extension])
    |> Map.put(:rel, to_string(relation_type))
    |> Map.merge(entry.extension)
    |> Map.to_list()
    |> Enum.filter(&has_value?/1)
    |> Enum.sort()
  end

  defp build_params(params) do
    params
    |> Enum.map(&build_single_param/1)
    |> Enum.join("; ")
  end

  defp build_single_param({key, value}) do
    ~s(#{key}="#{format_param_value(value)}")
  end

  defp format_param_value(value) when is_binary(value) do
    value
    |> String.replace("_", "-")
  end

  defp format_param_value(value) do
    value
    |> to_string()
  end

  defp has_value?({_key, nil}), do: false
  defp has_value?({_key, _value}), do: true
end
