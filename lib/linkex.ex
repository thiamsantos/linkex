defmodule Linkex do
  @moduledoc """
  Encode and decode HTTP Link headers.
  """

  alias Linkex.{Decoder, Encoder, LinkHeader}

  @doc """
  Encode a `Linkex.LinkHeader` struct to a Link HTTP header.
  """
  @spec encode(LinkHeader.t()) :: {:ok, String.t()}
  def encode(header), do: Encoder.encode(header)

  def encode!(header) do
    header
    |> encode()
    |> handle_result()
  end

  @doc """
  Decode a Link HTTP header to a `Linkex.LinkHeader` struct.
  """
  @spec decode(String.t()) :: {:ok, LinkHeader.t()}
  def decode(header), do: Decoder.decode(header)

  def decode!(header) do
    header
    |> decode()
    |> handle_result()
  end

  defp handle_result({:ok, result}), do: result
  defp handle_result({:error, error}), do: raise(error)
end
