defmodule InteractionsPlayground.SwPlug do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    |> put_resp_content_type("application/javascript")
    |> send_resp(200, "// no service worker in this playground\n")
  end
end
