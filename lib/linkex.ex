defmodule Linkex do
  @moduledoc """
  Documentation for Linkex.
  """

  alias Linkex.{Decoder, Encoder}

  def encode(header), do: Encoder.encode(header)

  def encode!(header) do
    header
    |> encode()
    |> handle_result()
  end

  def decode(header), do: Decoder.decode(header)

  def decode!(header) do
    header
    |> decode()
    |> handle_result()
  end

  defp handle_result({:ok, result}), do: result
  defp handle_result({:error, error}), do: raise(error)
end
