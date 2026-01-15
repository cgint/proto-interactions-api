defmodule InteractionsPlayground.SwPlug do
  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    |> Plug.Conn.put_resp_content_type("text/javascript")
    |> Plug.Conn.send_resp(200, "// no-op\n")
  end
end

