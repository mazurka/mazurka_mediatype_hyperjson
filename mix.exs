defmodule MazurkaMediatypeHyperjson.Mixfile do
  use Mix.Project

  def project do
    [app: :mazurka_mediatype_hyperjson,
     version: "0.0.1",
     elixir: "~> 1.0",
     deps: deps]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:poison, "~> 1.3.1" },
     {:etude, ">= 0.1.0" },
     {:mazurka_mediatype, ">= 0.1.0"}]
  end
end
