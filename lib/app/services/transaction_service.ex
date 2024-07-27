defmodule App.Service.Transaction do
  alias App.Repo
  alias App.Domain.Transaction

  def list_transactions do
    try do
      transactions = Repo.all(Transaction)
      count = length(transactions)

      {:ok, %{transactions: transactions, count: count}}
    rescue
      e -> {:error, {500, "Internal server error: #{e}"}}
    end
  end
end
