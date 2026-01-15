import Config

config :interactions_playground, InteractionsPlayground.Endpoint,
  debug_errors: true,
  code_reloader: true,
  live_reload: [
    patterns: [
      ~r"lib/.*(ex|heex)$",
      ~r"config/.*(exs)$"
    ]
  ]
