defmodule CertTest.Mixfile do
  use Mix.Project

  def project do
    [app: :brood,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [
      applications: [:logger, :cowboy, :plug, :plug_rest, :httpoison, :instream, :gen_mqtt, :satori, :wobserver],
      mod: {Brood.Application, []}
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 0.11.0"},
      {:cowboy, "~> 1.1"},
      {:plug, "~> 1.3"},
      {:plug_rest, "~> 0.12.0"},
      {:poison, "~> 3.0", override: true},
      {:instream, "~> 0.15.0"},
      {:gen_mqtt, "~> 0.3.1"},
      {:satori, "~> 0.2.0"},
      {:wobserver, "~> 0.1.7"}
    ]
  end
end
