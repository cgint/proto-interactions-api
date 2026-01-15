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

        <script>
          (function () {
            function init() {
              if (window.liveSocket) return;

              var meta = document.querySelector("meta[name='csrf-token']");
              if (!meta) return;
              var csrfToken = meta.getAttribute("content");

              var LiveSocket =
                (window.LiveView && window.LiveView.LiveSocket) ||
                (window.Phoenix && window.Phoenix.LiveView && window.Phoenix.LiveView.LiveSocket) ||
                window.LiveSocket;
              var Socket = (window.Phoenix && window.Phoenix.Socket) || window.Socket;

              if (!LiveSocket || !Socket) return;

              var liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}});
              liveSocket.connect();
              window.liveSocket = liveSocket;
            }

            if (document.readyState === "loading") {
              document.addEventListener("DOMContentLoaded", init);
            } else {
              init();
            }
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

