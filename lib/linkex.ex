defmodule Linkex do
  @moduledoc """
  Documentation for Linkex.
  """

  alias Linkex.{Decoder, Encoder}

  def encode(header), do: Encoder.encode(header)

  def encode!(header) do
    case decode(header) do
      {:ok, result} -> result
      {:error, error} -> raise error
    end
  end

  def decode(header), do: Decoder.decode(header)

  def decode!(header) do
    case decode(header) do
      {:ok, result} -> result
      {:error, error} -> raise error
    end
  end
end
