defmodule Mazurka.Mediatype do
  require Logger

  defmodule SyntaxError do
    defexception [:line, :file, :contents, :msg]

    def exception({line, file, contents, message}) do
      %SyntaxError{line: line, file: file, contents: contents, msg: message}
    end

    def message(%{line: line, file: file, contents: contents, msg: message}) do
      """      
      #{message}

      #{format_error(line, contents)}

      #{file}:#{line}
      """
    end

    defp format_error(line, {initial, contents}) do
      lines = String.split(contents, "\n")

      min = max((line - initial) - 5, 0)
      max = min((line - initial) + 5, length(lines))
      max_line_length = byte_size(to_string(max + initial))

      lines
      |> Enum.map_reduce(initial, fn
        (str, acc) ->
          {"#{highlight_line(acc, line)} #{pad_line_number(acc, max_line_length)} |  #{str}", acc + 1}
      end)
      |> elem(0)
      |> Enum.slice(min, max)
      |> Enum.join("\n")
    end

    defp highlight_line(line, line), do: ">"
    defp highlight_line(_, _), do: " "

    defp pad_line_number(line, max) do
      line = to_string(line)
      case max - byte_size(line) do
        0 -> line
        1 -> " #{line}"
        2 -> "  #{line}"
      end
    end
  end

  def parse(line, file, contents, mediatype) do
    parser = find_valid_parser(mediatype)
    chars = to_chars(contents)
    opts = [line: line, file: file]

    case apply(parser, :parse, [chars, opts]) do
      {:ok, ast} ->
        ## TODO transform the ast so we can handle side effects
        {:ok, ast}
      {:error, {eline, _, {:illegal, token}}} ->
        raise SyntaxError, {eline, file, {line, contents}, "illegal token: #{token}"}
      {:error, {eline, _, [error, token]}} ->
        raise SyntaxError, {eline, file, {line, contents}, "#{error}#{token}"}
    end
  end

  ## TODO
  defp find_valid_parser(parser) do
    parser
  end

  defp to_chars(bin) do
    case :unicode.characters_to_list(bin) do
      l when is_list(l) -> l
      _ -> :erlang.binary_to_list(bin)
    end
  end

end