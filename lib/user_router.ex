defmodule UsersRouter do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/" do
    send_resp(conn, 200, "List of users")
  end

  match "/", via: [:post, :patch, :put] do
    send_resp(conn, 405, "Method not allowed")
  end

  get "/:id" do
    send_resp(conn, 200, "User details for #{id}")
  end

  match "/:id", via: [:post, :patch, :put] do
    send_resp(conn, 405, "Method not allowed")
  end

  get "/:id/transactions" do
    send_resp(conn, 200, "List of transactions for user #{id}")
  end

  match "/:id/transactions", via: [:post, :patch, :put] do
    send_resp(conn, 405, "Method not allowed")
  end

  get "/:id/transactions/:tx" do
    send_resp(conn, 200, "Transaction details for user #{id} and transaction #{tx}")
  end

  match "/:id/transactions/:tx", via: [:post, :patch, :put] do
    send_resp(conn, 405, "Method not allowed")
  end

  get "/:id/transactions/status/:status" do
    send_resp(conn, 200, "List of transactions for user #{id} with status #{status}")
  end

  match "/:id/transactions/status/:status", via: [:post, :patch, :put] do
    send_resp(conn, 405, "Method not allowed")
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
