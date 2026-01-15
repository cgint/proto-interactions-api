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

