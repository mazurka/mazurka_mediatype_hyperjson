defmodule Mazurka.Mediatype.Hyperjson do
  def parse(src, opts \\ []) do
    line = Keyword.get(opts, :line, 1)
    case :mazurka_mediatype_hyperjson_lexer.string(src, line) do
      {:ok, [], _line} ->
        {:ok, []}
      {:ok, tokens, _line} ->
        :mazurka_mediatype_hyperjson_parser.parse(tokens)
      {:error, error} ->
        {:error, error}
      {:error, error, _line} ->
        {:error, error}
    end
  end

  def serialize(obj, opts \\ []) do
    Poison.encode_to_iodata!(obj, opts)
  end
end