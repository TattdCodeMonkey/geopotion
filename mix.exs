defmodule GeoPotion.Mixfile do
  use Mix.Project

  def project do
    [app: :geopotion,
     version: "0.1.1",
     elixir: ">= 1.0.0 and < 2.0.0",
     deps: deps(),
     package: package()]
  end

  def application do
    [applications: []]
  end

  defp deps do
    [{:dialyze, "~> 0.1.3", optional: true}]
  end

  defp package() do
    [files: ["lib", "mix.exs", "README.md", "LICENSE"],
      contributors: ["Rodney Norris"],
      licenses: ["Apache 2.0"],
      links: [{"Github", "https://github.com/tattdcodemonkey/geopotion"}]]
  end
end
