defmodule InteractionsPlayground.MixProject do
  use Mix.Project

  def project do
    [
      app: :interactions_playground,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {InteractionsPlayground.Application, []}
    ]
  end

  defp deps do
    [
      {:bandit, "~> 1.0"},
      {:finch, "~> 0.19"},
      {:jason, "~> 1.4"},
      {:phoenix, "~> 1.7"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_view, "~> 1.0"},
      {:phoenix_pubsub, "~> 2.1"}
    ]
  end
end
