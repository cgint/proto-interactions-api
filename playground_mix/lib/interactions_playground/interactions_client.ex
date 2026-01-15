defmodule InteractionsPlayground.InteractionsClient do
  alias InteractionsPlayground.Config
  alias InteractionsPlayground.SSE

  def stream_interaction(lv_pid, %{
        model: model,
        text: user_text,
        previous_interaction_id: prev_id
      }) do
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

    send(
      lv_pid,
      {:local_request, %{model: model, previous_interaction_id: prev_id, stream: true}}
    )

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
      Finch.stream(request, InteractionsPlayground.Finch, state, fun, receive_timeout: :infinity)

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
