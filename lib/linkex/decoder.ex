defmodule Linkex.Decoder do
  alias Linkex.{LinkHeader, Entry}

  @params_delimiter ";"
  @params_format ~r/(\w+)=\"?([\w\s\-]+)\"?/
  @link_delimiter ~r/,\s*</
  @link_format ~r/<?(.+)>;\s?(.+)/

  def decode(header) when is_binary(header) do
    decoded_header = header
    |> split_links()
    |> Enum.filter(&is_valid?/1)
    |> Enum.map(&parse_link/1)
    |> Enum.filter(&has_relation_type?/1)
    |> extract_relations()

    {:ok, decoded_header}
  end


  defp split_links(header) do
    String.split(header, @link_delimiter, trim: true)
  end

  defp is_valid?(link) do
    Regex.match?(@link_format, link)
  end

  defp parse_link(link) do
    [_, link, params] = Regex.run(@link_format, link)

    %{target: URI.parse(link), params: parse_params(params)}
  end

  defp parse_params(params) do
    params
    |> String.split(@params_delimiter, trim: true)
    |> Enum.map(fn(param) ->
        [_, name, value] = Regex.run(@params_format, param)
        {name, value}
      end)
    |> Enum.map(&transform_param/1)
    |> Enum.into(%{})
  end

  defp transform_param({"rel", value}) do
    relations = value
    |> String.split(" ")
    |> Enum.map(fn relation -> relation |> String.downcase() |> String.replace("-", "_") end)
    |> Enum.filter(fn relation -> Enum.member?(LinkHeader.valid_relations(), relation) end)

    {"rel", relations}
  end
  defp transform_param({name, value}) do
    {name, value}
  end

  defp has_relation_type?(link) do
    Map.has_key?(link.params, "rel")
  end

  defp extract_relations(links) do
    links
    |> Enum.flat_map(fn (item) ->
      item.params["rel"]
      |> Enum.map(fn relation ->
        %{target: item.target, params: Map.delete(item.params, "rel"), relation: relation}
      end)
    end)
    |> Enum.reduce(%LinkHeader{}, fn (item, acc) ->
      Map.put(acc, String.to_existing_atom(item.relation), extract_entry_values(item))
    end)
  end

  defp extract_entry_values(item) do
    entry = %Entry{target: item.target}

    item.params
    |> Map.to_list()
    |> Enum.reduce(entry, fn ({key, value}, acc) ->
      case Enum.member?(Entry.valid_values(), key) do
        true -> Map.put(acc, String.to_existing_atom(key), value)
        false -> put_in(acc.extension[key], value)
      end
    end)
  end
end
