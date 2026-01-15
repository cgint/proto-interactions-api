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
                  <span class="meta"><%= assistant_meta(turn) %></span>
                  <div class="msgs">
                    <%= for line <- (turn.lines || []) do %>
                      <div class="msgline"><%= line %></div>
                    <% end %>
                    <%= if (turn.stream_text || "") != "" do %>
                      <div class="msgline"><%= turn.stream_text %></div>
                    <% end %>
                  </div>
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
      .msgs { display: grid; gap: 6px; }
      .msgline {
        border-radius: 10px;
        border: 1px solid rgba(125, 140, 170, 0.18);
        background: rgba(125, 140, 170, 0.06);
        padding: 8px 10px;
        font-size: 13px;
        line-height: 1.35;
        white-space: pre-wrap;
        word-break: break-word;
      }
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
        lv_pid = self()

        socket =
          socket
          |> assign(draft: "")
          |> assign(streaming?: true, active_turn_id: turn_id)
          |> append_turn(%{
            id: turn_id,
            user_text: value,
            lines: [],
            stream_text: "",
            content_type: nil,
            seen: MapSet.new(),
            status: "queued",
            interaction_id: nil,
            error: nil
          })
          |> log_line(:user, "[user]", %{text: value})

        Task.start(fn ->
          InteractionsClient.stream_interaction(lv_pid, %{
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
    socket =
      socket
      |> log_line(:info, "[local.request]", %{request: request})
      |> update_active_turn(fn turn -> %{turn | status: "streaming"} end)

    {:noreply, socket}
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
    if content_event?(event, payload) do
      event_name = if is_binary(event), do: event, else: ""
      text_part = extract_text(payload)

      update_active_turn(socket, fn turn ->
        turn
        |> maybe_content_start(event_name, payload)
        |> maybe_append_text(event_name, text_part)
        |> maybe_content_stop(event_name, text_part)
        |> maybe_outputs(payload)
        |> maybe_finalize_on_stop(event_name)
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
    # Prefer "delta.text" if present (matches web_demo behavior).
    delta_text =
      case data["delta"] do
        %{"text" => t} when is_binary(t) and t != "" -> t
        _ -> nil
      end

    direct =
      (is_binary(data["text"]) && data["text"] != "" && data["text"]) ||
        (is_binary(data["delta"]) && data["delta"] != "" && data["delta"]) ||
        (is_binary(data["output_text"]) && data["output_text"] != "" && data["output_text"])

    cond do
      is_binary(delta_text) ->
        delta_text

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

  defp assistant_meta(turn) do
    status = Map.get(turn, :status)
    interaction_id = Map.get(turn, :interaction_id)

    cond do
      status in [nil, ""] ->
        "assistant:"

      status == "queued" ->
        "assistant: queued"

      true ->
        bits =
          []
          |> maybe_add_meta("status", status)
          |> maybe_add_meta("id", interaction_id)

        "assistant: " <> Enum.join(bits, "  ")
    end
  end

  defp maybe_add_meta(bits, _k, v) when v in [nil, ""], do: bits
  defp maybe_add_meta(bits, k, v), do: bits ++ ["#{k}=#{v}"]

  defp content_event?(event, payload) do
    (is_binary(event) and String.starts_with?(event, "content.")) or
      (is_map(payload) and is_list(payload["outputs"]) and payload["outputs"] != [])
  end

  defp maybe_content_start(turn, event_name, payload) do
    if String.contains?(event_name, "content.start") do
      content_type =
        case payload do
          %{"content" => %{"type" => t}} when is_binary(t) and t != "" -> t
          _ -> nil
        end

      turn
      |> finalize_stream_line()
      |> Map.put(:stream_text, "")
      |> Map.put(:content_type, content_type)
    else
      turn
    end
  end

  defp maybe_append_text(turn, event_name, text_part) do
    cond do
      not (is_binary(text_part) and text_part != "") ->
        turn

      Map.get(turn, :content_type) == "thought" ->
        turn

      String.contains?(event_name, "delta") ->
        Map.update(turn, :stream_text, text_part, &(&1 <> text_part))

      String.starts_with?(event_name, "content.") ->
        append_lines(turn, text_part)

      true ->
        append_lines(turn, text_part)
    end
  end

  defp maybe_content_stop(turn, event_name, text_part) do
    if String.contains?(event_name, "content.stop") and is_binary(text_part) and text_part != "" do
      turn
      |> Map.update(:stream_text, text_part, &(&1 <> text_part))
      |> finalize_stream_line()
    else
      turn
    end
  end

  defp maybe_finalize_on_stop(turn, event_name) do
    if String.contains?(event_name, "content.stop") do
      finalize_stream_line(turn)
    else
      turn
    end
  end

  defp maybe_outputs(turn, payload) do
    case payload do
      %{"outputs" => outputs} when is_list(outputs) ->
        Enum.reduce(outputs, turn, fn
          %{"text" => t}, acc when is_binary(t) and t != "" -> append_lines(acc, t)
          _, acc -> acc
        end)

      _ ->
        turn
    end
  end

  defp finalize_stream_line(turn) do
    text = Map.get(turn, :stream_text, "")

    turn
    |> Map.put(:stream_text, "")
    |> append_lines(text)
  end

  defp append_lines(turn, text) when not (is_binary(text) and text != ""), do: turn

  defp append_lines(turn, text) do
    text
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.filter(&(&1 != ""))
    |> Enum.reduce(turn, fn line, acc -> append_line(acc, line) end)
  end

  defp append_line(turn, line) do
    norm =
      line
      |> String.replace(~r/\s+/, " ")
      |> String.trim()

    if norm == "" do
      turn
    else
      seen = Map.get(turn, :seen, MapSet.new())

      if MapSet.member?(seen, norm) do
        turn
      else
        turn
        |> Map.update(:lines, [line], fn lines -> lines ++ [line] end)
        |> Map.put(:seen, MapSet.put(seen, norm))
      end
    end
  end

end
