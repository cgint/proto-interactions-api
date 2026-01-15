defmodule InteractionsPlayground.Port do
  @default_port 4000
  @max_tries 50

  def pick do
    base =
      case System.get_env("PORT") do
        nil -> @default_port
        "" -> @default_port
        value -> parse_port!(value)
      end

    find_available!(base)
  end

  defp parse_port!(value) do
    case Integer.parse(value) do
      {port, ""} when port > 0 and port < 65_536 ->
        port

      _ ->
        raise ArgumentError, "invalid PORT=#{inspect(value)} (expected 1..65535)"
    end
  end

  defp find_available!(base) do
    Enum.reduce_while(0..(@max_tries - 1), nil, fn offset, _acc ->
      port = base + offset

      case available?(port) do
        true -> {:halt, port}
        false -> {:cont, nil}
      end
    end) || raise("no available port found starting at #{base} (tried #{@max_tries} ports)")
  end

  defp available?(port) do
    opts = [:binary, active: false, ip: {127, 0, 0, 1}, reuseaddr: true]

    case :gen_tcp.listen(port, opts) do
      {:ok, socket} ->
        :ok = :gen_tcp.close(socket)
        true

      {:error, :eaddrinuse} ->
        false

      {:error, _} ->
        false
    end
  end
end
