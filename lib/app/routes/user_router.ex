defmodule UsersRouter do
  use Plug.Router

  import Plug.Conn

  alias App.Service.User

  plug(:match)
  plug(:dispatch)

  defp handle_error(conn, status_code, message) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status_code, Jason.encode!(%{error: message}))
  end

  get "/" do
    case User.list_users() do
      {:ok, users} -> send_resp(conn, 200, Jason.encode!(users))
      {:error, {status, message}} -> handle_error(conn, status, message)
    end
  end

  match "/", via: [:post, :patch, :put] do
    handle_error(conn, 405, "Method not allowed")
  end

  get "/:id" do
    case User.get_user(id) do
      {:ok, user} -> send_resp(conn, 200, Jason.encode!(user))
      {:error, {status, message}} -> handle_error(conn, status, message)
    end
  end

  match "/:id", via: [:post, :patch, :put] do
    handle_error(conn, 405, "Method not allowed")
  end

  get "/:id/transactions" do
    case User.list_user_transactions(id) do
      {:ok, transactions} -> send_resp(conn, 200, Jason.encode!(transactions))
      {:error, {status, message}} -> handle_error(conn, status, message)
    end
  end

  match "/:id/transactions", via: [:post, :patch, :put] do
    handle_error(conn, 405, "Method not allowed")
  end

  get "/:id/transactions/:tx" do
    case User.get_user_transaction(id, tx) do
      {:ok, transaction} -> send_resp(conn, 200, Jason.encode!(transaction))
      {:error, {status, message}} -> handle_error(conn, status, message)
    end
  end

  match "/:id/transactions/:tx", via: [:post, :patch, :put] do
    handle_error(conn, 405, "Method not allowed")
  end

  get "/:id/transactions/status/:status" do
    case User.list_user_transactions_by_status(id, status) do
      {:ok, transactions} -> send_resp(conn, 200, Jason.encode!(transactions))
      {:error, {status, message}} -> handle_error(conn, status, message)
    end
  end

  match "/:id/transactions/status/:status", via: [:post, :patch, :put] do
    handle_error(conn, 405, "Method not allowed")
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
