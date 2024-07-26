defmodule Router do
  use Plug.Router

  plug :match
  plug :dispatch

  forward "/users", to: UsersRouter
  forward "/transactions", to: TransactionsRouter

  get "/" do
    send_resp(conn, 200, "Deu bug, bebe elixir!!!")
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
