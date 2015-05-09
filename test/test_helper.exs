defmodule HyperjsonTestHelper do
  defmacro __using__(_) do
    quote do
      use ExUnit.Case, async: true
      import HyperjsonTestHelper
    end
  end

  @prefix Module.concat(["Mazurka", "Mediatype", "Test"])

  defmacro parsetest(name, str, expected) do
    mod = Module.concat([@prefix, to_string(:erlang.phash2(name))])
    quote do
      test unquote(name) do
        defmodule unquote(mod) do
          use Etude
          defetude :render, unquote(parse(__CALLER__, str))

          def resolve(:__internal, :resolve, ["rels", "self"], _, _, _, _) do
            {:ok, "/" <> unquote(name |> String.replace(" ", "-"))}
          end
          def resolve(:__internal, :"resolve-link", [_, args], _, _, _, _) do
            {:ok, %{"href" => "/" <> Enum.join(args, "/")}}
          end
          def resolve(_, _, args, _, _, _, _) do
            {:ok, args}
          end
        end
        {out, _state} = unquote(mod).render(:STATE, &unquote(mod).resolve/7)
        assert out == unquote(expected)
      end
    end
  end

  defmacro defpartial(mod, fun, str) do
    quote do
      defmodule unquote(mod) do
        use Etude
        defetude unquote(fun), unquote(parse(__CALLER__, str))
      end
    end
  end

  def parse(caller, str) do
    Macro.escape(elem(Mazurka.Mediatype.parse(caller.line + 1, caller.file, str, Mazurka.Mediatype.Hyperjson), 1))
  end
end

ExUnit.start()