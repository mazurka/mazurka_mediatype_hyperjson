defmodule HyperjsonTestHelper do
  defmacro __using__(_) do
    quote do
      use ExUnit.Case
      import HyperjsonTestHelper
    end
  end

  @prefix Module.concat(["Mazurka", "Mediatype", "Test"])

  defmacro parsetest(name, str, expected) do
    line = __CALLER__.line + 1
    file = __CALLER__.file
    mod = Module.concat([@prefix, to_string(:erlang.phash2(name))])

    quote do
      test unquote(name) do
        defmodule unquote(mod) do
          use Etude
          defetude :render,
            elem(Mazurka.Mediatype.parse(unquote(line), unquote(file), unquote(str), Mazurka.Mediatype.Hyperjson), 1)

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
end

ExUnit.start()