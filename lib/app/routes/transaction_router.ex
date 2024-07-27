defmodule TransactionsRouter do
  use Plug.Router

  import Plug.Conn

  alias App.Service.Transaction

  plug(:match)
  plug(:dispatch)

  defp handle_error(conn, status_code, message) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status_code, Jason.encode!(%{error: message}))
  end

  get "/" do
    case Transaction.list_transactions() do
      {:ok, transactions} -> send_resp(conn, 200, Jason.encode!(transactions))
      {:error, {status, message}} -> handle_error(conn, status, message)
    end
  end

  match "/", via: [:post, :patch, :put] do
    send_resp(conn, 405, "Method not allowed")
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
