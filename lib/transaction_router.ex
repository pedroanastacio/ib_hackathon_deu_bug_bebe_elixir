defmodule TransactionsRouter do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/" do
    send_resp(conn, 200, "List of transactions")
  end

  match "/", via: [:post, :patch, :put] do
    send_resp(conn, 405, "Method not allowed")
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
