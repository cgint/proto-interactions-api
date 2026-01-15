defmodule InteractionsPlayground.Router do
  use Phoenix.Router
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {InteractionsPlayground.Layout, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  get "/sw.js", InteractionsPlayground.SwPlug, []

  scope "/" do
    pipe_through :browser
    live "/", InteractionsPlayground.Live
    get "/health", InteractionsPlayground.HealthController, :index
  end
end
