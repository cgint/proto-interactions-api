defmodule InteractionsPlayground.Endpoint do
  use Phoenix.Endpoint, otp_app: :interactions_playground

  @session_options [
    store: :cookie,
    key: "_interactions_playground_key",
    signing_salt: "signing_salt"
  ]

  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]

  plug Plug.Logger
  plug Plug.Session, @session_options

  plug Plug.Static, from: {:phoenix, "priv/static"}, at: "/assets/phoenix"
  plug Plug.Static, from: {:phoenix_live_view, "priv/static"}, at: "/assets/phoenix_live_view"

  plug InteractionsPlayground.Router
end
