#!/usr/bin/env elixir

Mix.install([
  {:phoenix_playground, "~> 0.1.8"},
  {:phoenix, "~> 1.7"},
  {:phoenix_live_view, "~> 1.1"},
  {:bandit, "~> 1.0"},
  {:jason, "~> 1.4"},
  {:finch, "~> 0.19"}
])

base = __DIR__

Code.require_file(Path.join(base, "config.ex"))
Code.require_file(Path.join(base, "sse.ex"))
Code.require_file(Path.join(base, "interactions_client.ex"))
Code.require_file(Path.join(base, "controllers.ex"))
Code.require_file(Path.join(base, "sw_plug.ex"))
Code.require_file(Path.join(base, "errors.ex"))
Code.require_file(Path.join(base, "layout.ex"))
Code.require_file(Path.join(base, "live.ex"))
Code.require_file(Path.join(base, "router.ex"))
Code.require_file(Path.join(base, "endpoint.ex"))

{:ok, _} = Finch.start_link(name: InteractionsPlayground.Finch)

Application.put_env(
  :phoenix_playground,
  InteractionsPlayground.Endpoint,
  secret_key_base:
    System.get_env("PLAYGROUND_SECRET_KEY_BASE") ||
      "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
  render_errors: [
    formats: [html: InteractionsPlayground.ErrorHTML, json: InteractionsPlayground.ErrorJSON],
    layout: false
  ]
)

PhoenixPlayground.start(endpoint: InteractionsPlayground.Endpoint)

