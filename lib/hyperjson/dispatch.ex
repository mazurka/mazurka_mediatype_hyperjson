defmodule Mazurka.Mediatype.Parser.Hyperjson.Dispatch do
  falsy = [
    false,
    :undefined,
    nil
  ]

  for f <- falsy do
    for g <- falsy do
      def add(unquote(f), unquote(g)), do: unquote(f)
    end
    def add(unquote(f), val), do: val
    def add(val, unquote(f)), do: val
  end

  ## TODO make these a protocol

  def add(a, b) when is_map(a) and is_map(b) do
    Dict.merge(a, b)
  end
  def add(a, b) when (is_integer(a) or is_float(a)) and (is_integer(b) or is_float(b)) do
    a + b
  end
  def add(a, b) when is_binary(a) and is_binary(b) do
    a <> b
  end
  def add(a, b) when is_list(a) and is_list(b) do
    a ++ b
  end

  def equals(a, a), do: true
  def equals(_, _), do: false

  def notequals(a, a), do: false
  def notequals(_, _), do: true

  def lt(a, b), do: a < b
  def lte(a, b), do: a <= b
  def gt(a, b), do: a > b
  def gte(a, b), do: a >= b

  def append_hash(href, []), do: href
  for f <- falsy do
    def append_hash(href, unquote(f)), do: href
  end
  def append_hash(%{"href" => href} = obj, parts) when is_binary(href) do
    %{obj | "href" => append_hash(href, parts)}
  end
  def append_hash(href, parts) when is_binary(href) and is_list(parts) do
    :erlang.iolist_to_binary([href, "#", for part <- parts do
      ["/", part]
    end])
  end

  for f <- falsy do
    def to_map(unquote(f)), do: unquote(f)
  end
  def to_map(list) when is_list(list), do: :maps.from_list(list)

  for f <- falsy do
    def get(unquote(f), _), do: unquote(f)
    def get(unquote(f), _, _), do: unquote(f)
  end

  def get(parent, key) when is_atom(key) do
    Dict.get(parent, key) || Dict.get(parent, Atom.to_string(key))
  end
  def get(parent, key) when is_binary(key) do
    Dict.get(parent, key) || Dict.get(parent, String.to_atom(key))
  end
  def get(parent, key) do
    Dict.get(parent, key)
  end

  def get(parent, bin_key, atom_key) do
    Dict.get(parent, bin_key) || Dict.get(parent, atom_key)
  end

  def to_string(arg) do
    Kernel.to_string(arg)
  end

end
