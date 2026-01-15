import Config

config :phoenix, :json_library, Jason

config :interactions_playground, InteractionsPlayground.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  server: true,
  secret_key_base:
    System.get_env("PLAYGROUND_SECRET_KEY_BASE") ||
      System.get_env("SECRET_KEY_BASE") ||
      "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
  render_errors: [
    formats: [html: InteractionsPlayground.ErrorHTML, json: InteractionsPlayground.ErrorJSON],
    layout: false
  ],
  pubsub_server: InteractionsPlayground.PubSub,
  live_view: [signing_salt: "interactions_playground_salt"]

config :logger, :console, format: "[$level] $message\n"
