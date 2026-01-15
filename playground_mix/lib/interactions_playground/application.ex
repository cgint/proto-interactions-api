defmodule InteractionsPlayground.Application do
  use Application

  require Logger

  @impl true
  def start(_type, _args) do
    configure_endpoint()

    children = [
      {Phoenix.PubSub, name: InteractionsPlayground.PubSub},
      {Finch, name: InteractionsPlayground.Finch},
      InteractionsPlayground.Endpoint
    ]

    opts = [strategy: :one_for_one, name: InteractionsPlayground.Supervisor]
    result = Supervisor.start_link(children, opts)

    if match?({:ok, _}, result) do
      port =
        :interactions_playground
        |> Application.get_env(InteractionsPlayground.Endpoint, [])
        |> Keyword.get(:http, [])
        |> Keyword.get(:port, 4000)

      Logger.info("Access InteractionsPlayground.Endpoint at http://localhost:#{port}")
    end

    result
  end

  defp configure_endpoint do
    port = InteractionsPlayground.Port.pick()

    current =
      Application.get_env(:interactions_playground, InteractionsPlayground.Endpoint, [])

    updated =
      current
      |> Keyword.put(:http, ip: {127, 0, 0, 1}, port: port)

    Application.put_env(:interactions_playground, InteractionsPlayground.Endpoint, updated)
  end
end
