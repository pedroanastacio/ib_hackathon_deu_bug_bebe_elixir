defmodule App.Service.User do
  import Ecto.Query, only: [from: 2]
  require Logger

  alias App.Repo
  alias App.Domain.{User, Transaction}
  alias App.Transaction.Enums.Status
  alias App.RabbitMQ.Producer

  def handle_user_queue_message(payload) do
    with {:ok, user_event} <- Jason.decode(payload) do
      handle_event(user_event)
    else
      {:error, reason} ->
        Logger.error("Failed to decode user message: #{inspect(reason)}")
    end
  end

  defp handle_event(%{"event" => "User.Request"} = user_event) do
    case get_user_by_email(user_event["email"]) do
      {:ok, user} ->
        IO.inspect("User already exists: #{inspect(user)}")
        user_payload = invalid_user_data(user_event, "User already exists")
        Producer.publish_to_users(user_payload)

      {:error, {404, _}} ->
        IO.inspect("User does not exist")

        user_event
        |> Map.put(:status, "review")
        |> create_user()
        |> Producer.publish_to_users()

      {:error, _} = error ->
        Logger.error("Error fetching user: #{inspect(error)}")
    end
  end

  defp handle_event(%{"event" => "User.Created"} = payload) do
    payload
    |> Map.put(:status, "success")
    |> create_user()
    |> save_user()
    |> Producer.publish_to_users()
  end

  defp handle_event(%{"event" => "User.Pending"} = user_event) do
    if Map.has_key?(user_event, "reason") do
      IO.inspect("KYC added reason: #{user_event["reason"]}")
    else
      user_data = Map.put(user_event, :status, "success")
      Producer.publish_to_users(user_data)
    end
  end

  defp handle_event(%{"event" => event}) do
    Logger.warn("Unknown user event type: #{event}")
  end

  def list_users do
    try do
      users = Repo.all(User)
      count = length(users)

      {:ok, %{users: users, count: count}}
    rescue
      e -> {:error, {500, "Internal server error: #{e}"}}
    end
  end

  def get_user_by_id(id) do
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

  defp get_user_by_email(email) do
    try do
      case Repo.get_by(User, email: email) do
        nil -> {:error, {404, "User not found"}}
        user -> {:ok, user}
      end
    rescue
      e -> {:error, {500, "Internal server error: #{e.message}"}}
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

  def create_user(user) do
    User.changeset(%User{}, %{
      id: Ecto.UUID.generate(),
      name: user["name"],
      email: user["email"],
      public_key: user["public_key"],
      status: user["status"],
      currency: user["currency"],
      balance: user["balance"],
      created_at: user["created_at"],
      updated_at: user["updated_at"]
    })
  end

  def save_user(changeset) do
    try do
      case Repo.insert(changeset) do
        {:ok, user} -> {:ok, user}
        {:error, changeset} -> {:error, {400, "Invalid user data"}}
      end
    rescue
      e -> {:error, {500, "Internal server error: #{Exception.message(e)}"}}
    end
  end

  def invalid_user_data(payload, reason) do
    User.changeset(%User{}, %{
      id: Ecto.UUID.generate(),
      name: payload["name"],
      email: payload["email"],
      public_key: payload["public_key"],
      status: "failed",
      currency: payload["currency"],
      balance: payload["balance"],
      created_at: payload["created_at"],
      updated_at: payload["updated_at"],
      reason: reason
    })
  end
end
