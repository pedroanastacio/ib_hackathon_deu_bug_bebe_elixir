defmodule DeuBugBebeElixirNg.MixProject do
  use Mix.Project

  def project do
    [
      app: :deu_bug_bebe_elixir_ng,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {App, []},
      appications: [:amqp]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 2.5"},
      {:jason, "~> 1.3"},
      {:ecto_sql, "~> 3.6"},
      {:postgrex, ">= 0.0.0"},
      {:amqp, "~> 3.0.0"},
      {:ex_keccak, "~> 0.7.4"}
    ]
  end
end
