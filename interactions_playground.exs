#!/usr/bin/env elixir

Mix.install([
  {:phoenix_playground, "~> 0.1.8"},
  {:phoenix, "~> 1.7"},
  {:phoenix_live_view, "~> 1.1"},
  {:bandit, "~> 1.0"},
  {:jason, "~> 1.4"},
  {:finch, "~> 0.19"}
])

defmodule InteractionsPlayground.Config do
  @interactions_base_url "https://generativelanguage.googleapis.com"
  @interactions_version "v1beta"
  @default_model "gemini-2.5-flash"

  def interactions_url do
    "#{@interactions_base_url}/#{@interactions_version}/interactions"
  end

  def default_model, do: @default_model

  def require_api_key do
    System.get_env("GEMINI_API_KEY") || System.get_env("GOOGLE_API_KEY") ||
      raise("""
      Missing API key: set GEMINI_API_KEY (or GOOGLE_API_KEY) in your environment.
      """)
  end
end

defmodule InteractionsPlayground.SSE do
  def parse_chunks(chunks, initial_buffer \\ "") do
    Enum.reduce(chunks, {[], initial_buffer}, fn chunk, {events, buffer} ->
      parse_chunk(events, buffer, chunk)
    end)
  end

  def parse_chunk(events, buffer, chunk) when is_binary(buffer) and is_binary(chunk) do
    data = (buffer <> chunk) |> String.replace("\r\n", "\n")

    case String.split(data, "\n\n") do
      [incomplete] ->
        {events, incomplete}

      parts ->
        {complete, [tail]} = Enum.split(parts, -1)
        new_events = Enum.flat_map(complete, &parse_event_block/1)
        {events ++ new_events, tail}
    end
  end

  defp parse_event_block(block) when is_binary(block) do
    lines =
      block
      |> String.split("\n")
      |> Enum.map(&String.trim_trailing/1)

    parsed =
      Enum.reduce(lines, %{event: nil, id: nil, data_lines: []}, fn line, acc ->
        cond do
          line == "" ->
            acc

          String.starts_with?(line, ":") ->
            acc

          String.starts_with?(line, "event:") ->
            %{acc | event: String.trim_leading(String.replace_prefix(line, "event:", ""))}

          String.starts_with?(line, "id:") ->
            %{acc | id: String.trim_leading(String.replace_prefix(line, "id:", ""))}

          String.starts_with?(line, "data:") ->
            data = String.replace_prefix(line, "data:", "") |> String.trim_leading()
            %{acc | data_lines: acc.data_lines ++ [data]}

          true ->
            acc
        end
      end)

    if parsed.data_lines == [] do
      []
    else
      [
        %{
          event: parsed.event,
          id: parsed.id,
          data: Enum.join(parsed.data_lines, "\n")
        }
      ]
    end
  end
end

defmodule InteractionsPlayground.InteractionsClient do
  alias InteractionsPlayground.Config
  alias InteractionsPlayground.SSE

  def stream_interaction(lv_pid, %{model: model, text: user_text, previous_interaction_id: prev_id}) do
    url = Config.interactions_url()
    api_key = Config.require_api_key()

    request_body =
      %{
        model: model,
        input: user_text,
        stream: true,
        store: true
      }
      |> maybe_put_previous(prev_id)

    headers = [
      {"x-goog-api-key", api_key},
      {"accept", "text/event-stream"},
      {"content-type", "application/json"}
    ]

    send(lv_pid, {:local_request, %{model: model, previous_interaction_id: prev_id, stream: true}})

    request =
      Finch.build(:post, url, headers, Jason.encode!(request_body))

    state = %{
      status: nil,
      headers: [],
      error_body: "",
      buffer: ""
    }

    fun = fn
      {:status, status}, acc ->
        %{acc | status: status}

      {:headers, headers}, acc ->
        %{acc | headers: headers}

      {:data, chunk}, %{status: status} = acc when is_integer(status) and status >= 400 ->
        %{acc | error_body: acc.error_body <> chunk}

      {:data, chunk}, acc ->
        {events, buffer} = SSE.parse_chunk([], acc.buffer, chunk)

        Enum.each(events, fn ev ->
          payload =
            case Jason.decode(ev.data) do
              {:ok, decoded} -> decoded
              _ -> %{"raw" => ev.data}
            end

          send(lv_pid, {:interactions_sse, %{event: ev.event, id: ev.id, data: payload}})
        end)

        %{acc | buffer: buffer}

      _, acc ->
        acc
    end

    result =
      Finch.stream(request, InteractionsPlayground.Finch, state, fun,
        receive_timeout: :infinity
      )

    case result do
      {:ok, %{status: status, error_body: body}} when is_integer(status) and status >= 400 ->
        send(lv_pid, {:interactions_error, %{status_code: status, body: body}})

      {:ok, _} ->
        send(lv_pid, :interactions_done)

      {:error, reason} ->
        send(lv_pid, {:local_error, %{message: Exception.format_exit(reason)}})
    end
  rescue
    e ->
      send(lv_pid, {:local_error, %{message: Exception.message(e)}})
  end

  defp maybe_put_previous(map, nil), do: map
  defp maybe_put_previous(map, ""), do: map
  defp maybe_put_previous(map, prev_id), do: Map.put(map, :previous_interaction_id, prev_id)
end

defmodule InteractionsPlayground.HealthController do
  use Phoenix.Controller, formats: [:json]

  def index(conn, _params) do
    Phoenix.Controller.json(conn, %{ok: true, model: InteractionsPlayground.Config.default_model()})
  end
end

defmodule InteractionsPlayground.SwPlug do
  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    |> Plug.Conn.put_resp_content_type("text/javascript")
    |> Plug.Conn.send_resp(200, "// no-op\n")
  end
end

defmodule InteractionsPlayground.ErrorHTML do
  use Phoenix.Component

  def render(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end

defmodule InteractionsPlayground.ErrorJSON do
  def render(template, _assigns) do
    %{error: Phoenix.Controller.status_message_from_template(template)}
  end
end

defmodule InteractionsPlayground.Layout do
  use Phoenix.Component

  def root(assigns) do
    ~H"""
    <!doctype html>
    <html lang="en">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width,initial-scale=1" />
        <meta name="csrf-token" content={Plug.CSRFProtection.get_csrf_token()} />
        <title>Interactions Playground</title>

        <script defer src="/assets/phoenix/phoenix.js"></script>
        <script defer src="/assets/phoenix_live_view/phoenix_live_view.js"></script>

        <script defer>
          (function () {
            if (window.liveSocket) return;
            var meta = document.querySelector("meta[name='csrf-token']");
            if (!meta) return;
            var csrfToken = meta.getAttribute("content");
            if (!window.LiveView || !window.LiveView.LiveSocket || !window.Phoenix || !window.Phoenix.Socket) return;
            var liveSocket = new window.LiveView.LiveSocket("/live", window.Phoenix.Socket, {params: {_csrf_token: csrfToken}});
            liveSocket.connect();
            window.liveSocket = liveSocket;
          })();
        </script>
      </head>
      <body>
        <%= @inner_content %>
      </body>
    </html>
    """
  end
end

defmodule InteractionsPlayground.Live do
  use Phoenix.LiveView

  alias InteractionsPlayground.Config
  alias InteractionsPlayground.InteractionsClient

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(
        model: Config.default_model(),
        draft: "",
        streaming?: false,
        previous_interaction_id: nil,
        latest_interaction_id: nil,
        log: [],
        turns: [],
        active_turn_id: nil,
        init_error: nil
      )
      |> log_line(:info, "[local] mounted", %{
        note: "LiveView connected; streaming uses server-side SSE consumption",
        model: Config.default_model()
      })

    {:ok, socket}
  rescue
    e ->
      {:ok, assign(socket, init_error: Exception.message(e))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="page">
      <header>
        <h1>Gemini Interactions API — minimal streaming demo (LiveView Playground)</h1>
        <div class="hint">
          Type and press Enter. Use <span class="mono">/new</span> to reset conversation.
        </div>
      </header>

      <main>
        <div id="panes">
          <section id="log">
            <p class="paneTitle">Raw event log</p>
            <%= for entry <- @log do %>
              <div class={"line " <> entry_class(entry.kind)}>
                <%= entry.label %>
                <%= if entry.payload != nil do %>
                  <pre><%= format_payload(entry.payload) %></pre>
                <% end %>
              </div>
            <% end %>
          </section>

          <section id="summary">
            <p class="paneTitle">
              <%= if @latest_interaction_id do %>
                Summary (interaction: <%= @latest_interaction_id %>)
              <% else %>
                Summary (human-friendly)
              <% end %>
            </p>

            <%= for turn <- @turns do %>
              <div class="turn">
                <div class="bubble user"><%= turn.user_text %></div>
                <div class="bubble assistant">
                  <span class="meta">
                    assistant:
                    <%= if turn.status, do: " status=#{turn.status}", else: "" %>
                    <%= if turn.interaction_id, do: "  id=#{turn.interaction_id}", else: "" %>
                  </span>
                  <div><%= turn.assistant_text || "" %></div>
                  <%= if turn.error do %>
                    <div class="errText"><%= turn.error %></div>
                  <% end %>
                </div>
              </div>
            <% end %>
          </section>
        </div>

        <.form for={%{}} id="chat" phx-submit="send" class="chatForm">
          <input
            id="text"
            name="text"
            type="text"
            value={@draft}
            autocomplete="off"
            placeholder="Ask something… (e.g. 'Explain SSE in 2 sentences')"
            disabled={@streaming? or @init_error != nil}
          />
          <button class="primary" type="submit" disabled={@streaming? or @init_error != nil}>
            <%= if @streaming?, do: "Streaming…", else: "Send" %>
          </button>
          <button type="button" phx-click="clear" disabled={@streaming?}>Clear</button>
        </.form>

        <%= if @init_error do %>
          <div class="initError">
            <strong>Server config error:</strong> <%= @init_error %>
          </div>
        <% end %>
      </main>
    </div>

    <style>
      :root {
        color-scheme: light dark;
        --bg: #0b0d12;
        --panel: #121624;
        --muted: #a3adc2;
        --text: #e7ecf8;
        --accent: #7aa2ff;
        --user: #00d4ff;
        --err: #ff6b6b;
        --mono: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono",
          "Courier New", monospace;
      }
      @media (prefers-color-scheme: light) {
        :root {
          --bg: #f6f8ff;
          --panel: #ffffff;
          --muted: #4b5568;
          --text: #111827;
          --accent: #245dff;
          --user: #0f766e;
          --err: #b42318;
        }
      }
      * { box-sizing: border-box; }
      body { margin: 0; background: var(--bg); color: var(--text); font-family: system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial, sans-serif; }
      header {
        padding: 16px 18px;
        border-bottom: 1px solid rgba(125, 140, 170, 0.25);
        display: flex;
        gap: 12px;
        align-items: baseline;
        justify-content: space-between;
      }
      header h1 { margin: 0; font-size: 14px; font-weight: 650; letter-spacing: 0.2px; }
      header .hint { font-size: 12px; color: var(--muted); }
      .mono { font-family: var(--mono); }
      main { display: grid; grid-template-rows: 1fr auto auto; height: calc(100vh - 56px); }
      #panes { display: grid; grid-template-columns: 1fr 1fr; min-height: 0; }
      #log { padding: 14px 18px; overflow: auto; min-height: 0; border-right: 1px solid rgba(125, 140, 170, 0.25); }
      #summary { padding: 14px 18px; overflow: auto; min-height: 0; }
      .paneTitle { font-size: 12px; color: var(--muted); margin: 0 0 10px; letter-spacing: 0.2px; text-transform: uppercase; }
      .turn { margin: 12px 0; display: grid; gap: 8px; }
      .bubble {
        border-radius: 12px;
        border: 1px solid rgba(125, 140, 170, 0.18);
        background: rgba(125, 140, 170, 0.08);
        padding: 10px 12px;
        white-space: pre-wrap;
        word-break: break-word;
      }
      .bubble.user { border-color: rgba(0, 212, 255, 0.35); background: rgba(0, 212, 255, 0.08); }
      .bubble.assistant { border-color: rgba(122, 162, 255, 0.35); background: rgba(122, 162, 255, 0.06); }
      .bubble .meta { display: block; font-size: 12px; color: var(--muted); margin-bottom: 6px; font-family: var(--mono); }
      .errText { margin-top: 8px; color: var(--err); font-family: var(--mono); font-size: 12px; }

      .line {
        font-family: var(--mono);
        font-size: 12px;
        line-height: 1.35;
        white-space: pre-wrap;
        word-break: break-word;
        padding: 8px 10px;
        margin: 8px 0;
        background: rgba(125, 140, 170, 0.08);
        border: 1px solid rgba(125, 140, 170, 0.18);
        border-radius: 10px;
      }
      .line pre { margin: 8px 0 0; white-space: pre-wrap; }
      .line.user { border-color: rgba(0, 212, 255, 0.35); background: rgba(0, 212, 255, 0.08); }
      .line.err { border-color: rgba(255, 107, 107, 0.45); background: rgba(255, 107, 107, 0.08); }

      .chatForm {
        padding: 14px 18px 18px;
        border-top: 1px solid rgba(125, 140, 170, 0.25);
        display: grid;
        grid-template-columns: 1fr auto auto;
        gap: 10px;
        background: color-mix(in oklab, var(--panel) 90%, transparent);
      }
      input[type="text"] {
        width: 100%;
        border-radius: 10px;
        border: 1px solid rgba(125, 140, 170, 0.35);
        background: var(--panel);
        color: var(--text);
        padding: 10px 12px;
        font-size: 13px;
        outline: none;
      }
      input[type="text"]:focus {
        border-color: color-mix(in oklab, var(--accent) 70%, transparent);
        box-shadow: 0 0 0 3px color-mix(in oklab, var(--accent) 18%, transparent);
      }
      button {
        border-radius: 10px;
        border: 1px solid rgba(125, 140, 170, 0.35);
        background: var(--panel);
        color: var(--text);
        padding: 10px 12px;
        font-size: 13px;
        cursor: pointer;
      }
      button.primary {
        border-color: color-mix(in oklab, var(--accent) 55%, transparent);
        background: color-mix(in oklab, var(--accent) 15%, var(--panel));
      }
      button[disabled], input[disabled] { opacity: 0.6; cursor: not-allowed; }
      .initError {
        padding: 12px 18px;
        border-top: 1px solid rgba(255, 107, 107, 0.35);
        color: var(--err);
        font-family: var(--mono);
        font-size: 12px;
      }
    </style>
    """
  end

  @impl true
  def handle_event("send", %{"text" => _text}, %{assigns: %{streaming?: true}} = socket) do
    {:noreply, log_line(socket, :err, "[local] busy", %{message: "already streaming; wait for completion"})}
  end

  def handle_event("send", %{"text" => text}, socket) do
    value = text |> to_string() |> String.trim()

    cond do
      value == "" ->
        {:noreply, socket}

      value in ["/new", "/reset"] ->
        socket =
          socket
          |> assign(previous_interaction_id: nil)
          |> log_line(:info, "[local.info]", %{
            message: "Started a new interaction (cleared previous_interaction_id)."
          })

        {:noreply, socket}

      true ->
        turn_id = System.unique_integer([:positive, :monotonic])

        socket =
          socket
          |> assign(draft: "")
          |> assign(streaming?: true, active_turn_id: turn_id)
          |> append_turn(%{
            id: turn_id,
            user_text: value,
            assistant_text: "",
            status: nil,
            interaction_id: nil,
            error: nil
          })
          |> log_line(:user, "[user]", %{text: value})

        Task.start(fn ->
          InteractionsClient.stream_interaction(self(), %{
            model: socket.assigns.model,
            text: value,
            previous_interaction_id: socket.assigns.previous_interaction_id
          })
        end)

        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("clear", _params, socket) do
    {:noreply,
     assign(socket,
       log: [],
       turns: [],
       active_turn_id: nil,
       latest_interaction_id: nil
     )}
  end

  @impl true
  def handle_info({:local_request, request}, socket) do
    {:noreply, log_line(socket, :info, "[local.request]", %{request: request})}
  end

  def handle_info({:interactions_error, %{status_code: status, body: body}}, socket) do
    socket =
      socket
      |> log_line(:err, "[interactions.error]", %{status_code: status, body: body})
      |> set_active_turn_error("HTTP #{status}")
      |> assign(streaming?: false)

    {:noreply, socket}
  end

  def handle_info({:local_error, %{message: message}}, socket) do
    socket =
      socket
      |> log_line(:err, "[local.error]", %{message: message})
      |> set_active_turn_error(message)
      |> assign(streaming?: false)

    {:noreply, socket}
  end

  def handle_info(:interactions_done, socket) do
    {:noreply, assign(socket, streaming?: false)}
  end

  def handle_info({:interactions_sse, %{event: event, id: id, data: payload}}, socket) do
    socket =
      socket
      |> log_line(:info, "[interactions.sse] #{event || ""}" |> String.trim(), %{
        event: event,
        id: id,
        data: payload
      })
      |> maybe_update_interaction_id(payload)
      |> maybe_update_status(payload)
      |> maybe_update_text(event, payload)

    {:noreply, socket}
  end

  defp maybe_update_interaction_id(socket, payload) do
    interaction_id = extract_interaction_id(payload)

    if is_binary(interaction_id) and interaction_id != "" do
      socket
      |> assign(previous_interaction_id: interaction_id, latest_interaction_id: interaction_id)
      |> update_active_turn(fn turn -> %{turn | interaction_id: interaction_id} end)
    else
      socket
    end
  end

  defp maybe_update_status(socket, payload) do
    status = extract_status(payload)

    if is_binary(status) and status != "" do
      update_active_turn(socket, fn turn -> %{turn | status: status} end)
    else
      socket
    end
  end

  defp maybe_update_text(socket, event, payload) do
    text_part = extract_text(payload)

    if is_binary(text_part) and text_part != "" do
      is_delta =
        is_binary(event) and String.contains?(event, "delta")

      update_active_turn(socket, fn turn ->
        current = turn.assistant_text || ""

        new_text =
          cond do
            is_delta ->
              current <> text_part

            current == "" ->
              text_part

            String.length(text_part) > String.length(current) ->
              text_part

            true ->
              current
          end

        %{turn | assistant_text: new_text}
      end)
    else
      socket
    end
  end

  defp extract_interaction_id(%{"interaction" => %{"id" => id}}) when is_binary(id) and id != "", do: id
  defp extract_interaction_id(%{"id" => id}) when is_binary(id) and id != "", do: id
  defp extract_interaction_id(_), do: nil

  defp extract_status(%{"status" => status}) when is_binary(status) and status != "", do: status
  defp extract_status(%{"interaction" => %{"status" => status}}) when is_binary(status) and status != "", do: status

  defp extract_status(%{"status_update" => %{"status" => status}})
       when is_binary(status) and status != "",
       do: status

  defp extract_status(_), do: nil

  defp extract_text(data) when is_binary(data), do: data

  defp extract_text(data) when is_map(data) do
    direct =
      (is_binary(data["text"]) && data["text"] != "" && data["text"]) ||
        (is_binary(data["delta"]) && data["delta"] != "" && data["delta"]) ||
        (is_binary(data["output_text"]) && data["output_text"] != "" && data["output_text"])

    cond do
      is_binary(direct) ->
        direct

      is_map(data["content"]) ->
        extract_text_from_content(data["content"])

      is_list(data["outputs"]) ->
        outputs_to_text(data["outputs"])

      true ->
        nil
    end
  end

  defp extract_text(_), do: nil

  defp extract_text_from_content(%{"text" => text}) when is_binary(text) and text != "", do: text
  defp extract_text_from_content(%{"delta" => text}) when is_binary(text) and text != "", do: text

  defp extract_text_from_content(%{"parts" => parts}) when is_list(parts) do
    parts
    |> Enum.flat_map(fn
      %{"text" => t} when is_binary(t) and t != "" -> [t]
      _ -> []
    end)
    |> Enum.join("")
    |> case do
      "" -> nil
      joined -> joined
    end
  end

  defp extract_text_from_content(_), do: nil

  defp outputs_to_text(outputs) do
    parts =
      Enum.flat_map(outputs, fn
        %{"text" => t} when is_binary(t) and t != "" ->
          [t]

        %{"content" => %{"parts" => parts}} when is_list(parts) ->
          Enum.flat_map(parts, fn
            %{"text" => t} when is_binary(t) and t != "" -> [t]
            _ -> []
          end)

        _ ->
          []
      end)

    case Enum.join(parts, "") do
      "" -> nil
      joined -> joined
    end
  end

  defp append_turn(socket, turn) do
    assign(socket, turns: socket.assigns.turns ++ [turn])
  end

  defp update_active_turn(socket, fun) do
    active_id = socket.assigns.active_turn_id

    turns =
      Enum.map(socket.assigns.turns, fn turn ->
        if turn.id == active_id, do: fun.(turn), else: turn
      end)

    assign(socket, turns: turns)
  end

  defp set_active_turn_error(socket, message) do
    update_active_turn(socket, fn turn -> %{turn | error: message, status: "error"} end)
  end

  defp log_line(socket, kind, label, payload) do
    entry = %{kind: kind, label: label, payload: payload}
    assign(socket, log: socket.assigns.log ++ [entry])
  end

  defp entry_class(:user), do: "user"
  defp entry_class(:err), do: "err"
  defp entry_class(_), do: ""

  defp format_payload(payload) do
    cond do
      is_binary(payload) ->
        payload

      true ->
        case Jason.encode(payload, pretty: true) do
          {:ok, json} -> json
          _ -> inspect(payload)
        end
    end
  end
end

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

defmodule InteractionsPlayground.Endpoint do
  use Phoenix.Endpoint, otp_app: :phoenix_playground

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
