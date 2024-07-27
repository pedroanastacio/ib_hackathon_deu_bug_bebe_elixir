defmodule App.Service.User do
  import Ecto.Query, only: [from: 2]

  alias App.Repo
  alias App.Domain.{User, Transaction}
  alias App.Transaction.Enums.Status

  def list_users do
    try do
      users = Repo.all(User)
      count = length(users)

      {:ok, %{users: users, count: count}}
    rescue
      e -> {:error, {500, "Internal server error: #{e}"}}
    end
  end

  def get_user(id) do
    case Ecto.UUID.cast(id) do
      {:ok, binary_id} ->
        try do
          user = Repo.get(User, binary_id)

          case user do
            nil -> {:error, {404, "User not found"}}
            _ -> {:ok, user}
          end
        rescue
          e -> {:error, {500, "Internal server error: #{e.message}"}}
        end

      :error ->
        {:error, {400, "Invalid user ID"}}
    end
  end

  def list_user_transactions(id) do
    case Ecto.UUID.cast(id) do
      {:ok, binary_id} ->
        case Repo.get(User, binary_id) do
          nil ->
            {:error, {404, "User not found"}}

          _user ->
            try do
              query =
                from(t in Transaction,
                  where: t.sender_id == ^binary_id or t.receiver_id == ^binary_id
                )

              transactions = Repo.all(query)
              count = length(transactions)

              {:ok,
               %{
                 user_id: id,
                 transactions: transactions,
                 count: count
               }}
            rescue
              e -> {:error, {500, "Internal server error: #{Exception.message(e)}"}}
            end
        end

      :error ->
        {:error, {400, "Invalid user ID"}}
    end
  end

  def get_user_transaction(id, tx_id) do
    case Ecto.UUID.cast(id) do
      {:ok, binary_id} ->
        case Ecto.UUID.cast(tx_id) do
          {:ok, tx_binary_id} ->
            case Repo.get(Transaction, tx_binary_id) do
              nil ->
                {:error, {404, "User or transaction not found"}}

              transaction ->
                if transaction.sender_id == binary_id or transaction.receiver_id == binary_id do
                  user = Repo.get(User, id)

                  {:ok,
                   %{
                     sender: user,
                     id: transaction.id,
                     amount: transaction.amount,
                     currency: transaction.currency,
                     hash: transaction.hash,
                     status: transaction.status,
                     reason: transaction.reason,
                     sender_id: transaction.sender_id,
                     receiver_id: transaction.receiver_id,
                     created_at: transaction.created_at,
                     updated_at: transaction.updated_at
                   }}
                else
                  {:error, {404, "User or transaction not found"}}
                end
            end

          :error ->
            {:error, {400, "Invalid transaction ID"}}
        end

      :error ->
        {:error, {400, "Invalid user ID"}}
    end
  end

  def list_user_transactions_by_status(id, status) do
    case Ecto.UUID.cast(id) do
      {:ok, binary_id} ->
        if not Status.valid?(status) do
          {:error, {400, "Invalid status"}}
        else
          case Repo.get(User, binary_id) do
            nil ->
              {:error, {404, "User not found"}}

            _user ->
              try do
                query =
                  from(t in Transaction,
                    where: t.sender_id == ^binary_id or t.receiver_id == ^binary_id,
                    where: t.status == ^status
                  )

                transactions = Repo.all(query)
                count = length(transactions)

                {:ok,
                 %{
                   user_id: id,
                   transactions: transactions,
                   count: count
                 }}
              rescue
                e -> {:error, {500, "Internal server error: #{Exception.message(e)}"}}
              end
          end
        end

      :error ->
        {:error, {400, "Invalid user ID"}}
    end
  end
end
