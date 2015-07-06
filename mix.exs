defmodule MazurkaMediatypeHyperjson.Mixfile do
  use Mix.Project

  def project do
    [app: :mazurka_mediatype_hyperjson,
     version: "0.1.4",
     elixir: "~> 1.0",
     description: "hyper+json mediatype compiler for mazurka",
     package: package,
     deps: deps]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:poison, "~> 1.3.1" },
     {:etude, ">= 0.1.0" },
     {:mazurka_mediatype, ">= 0.2.0"},
     {:parse_trans, github: "uwiger/parse_trans", only: [:dev, :test]}]
  end

  defp package do
    [files: ["lib", "src/*.xrl", "src/*.yrl", "mix.exs", "README*"],
     contributors: ["Cameron Bytheway"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/mazurka/mazurka_mediatype_hyperjson"}]
  end
end
