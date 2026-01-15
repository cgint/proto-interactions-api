defmodule InteractionsPlayground.HealthController do
  use Phoenix.Controller, formats: [:json]

  def index(conn, _params) do
    Phoenix.Controller.json(conn, %{ok: true, model: InteractionsPlayground.Config.default_model()})
  end
end

