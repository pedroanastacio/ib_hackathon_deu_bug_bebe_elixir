defmodule App.Service.Transaction do
  import Ecto.Query
  require Logger

  alias App.Repo
  alias App.Domain.{Transaction, User}
  alias App.RabbitMQ.Producer
  alias App.Utils.{Hash, CurrencyConverter}

  alias Ecto.UUID

  def list_transactions do
    try do
      transactions = Repo.all(Transaction)
      count = length(transactions)

      {:ok, %{transactions: transactions, count: count}}
    rescue
      e -> {:error, {500, "Internal server error: #{e}"}}
    end
  end

  def create_transaction(payload) do
    case Jason.decode(payload, keys: :atoms) do
      {:ok, decoded_payload} ->
        Logger.info("Decoded payload: #{inspect(decoded_payload)}")

        case decoded_payload.event do
          "Transaction.Request" ->
            Logger.info("Transaction request: #{inspect(payload)}")
            create_transaction_request(decoded_payload)

          "Transaction.Created" ->
            create_transaction_approved(decoded_payload)

          "Transaction.Pending" ->
            create_transaction_pending(decoded_payload)

          _ ->
            {:error, {400, "Bad request: Invalid event"}}
        end

      {:error, reason} ->
        Logger.error("Failed to decode payload: #{inspect(reason)} for payload: #{payload}")
    end
  end

  defp payload_validation(payload) do
    cond do
      not Map.has_key?(payload, :event) ->
        {:error, {400, "Bad request: event is required"}}

      not Map.has_key?(payload, :sender) ->
        {:error, {400, "Bad request: sender is required"}}

      not Map.has_key?(payload, :receiver) ->
        {:error, {400, "Bad request: receiver is required"}}

      not Map.has_key?(payload, :amount) ->
        {:error, {400, "Bad request: amount is required"}}

      not Map.has_key?(payload, :currency) ->
        {:error, {400, "Bad request: currency is required"}}

      not Map.has_key?(payload, :hash) ->
        {:error, {400, "Bad request: hash is required"}}

      true ->
        true
    end
  end

  defp create_transaction_request(payload) do
    case payload_validation(payload) do
      true ->
        try do
          user_sender = Repo.get(User, payload.sender)
          user_receiver = Repo.get(User, payload.receiver)

          if user_receiver && user_sender do
            if user_sender.balance >= payload.amount do
              id = UUID.generate()

              Producer.publish_to_transactions(%{
                event: "Transaction.Pending",
                sender: payload.sender,
                receiver: payload.receiver,
                amount: payload.amount,
                currency: payload.currency,
                hash: payload.hash,
                created_at: payload.created_at,
                id: id,
                status: "review",
                updated_at: DateTime.utc_now().to_string()
              })

              Logger.info("Transaction request: #{inspect(payload)}")

              {:ok, %{id: id}}
            else
              publish_failure(payload, "Insufficient balance")
              {:error, {400, "Bad request: Insufficient balance"}}
            end
          else
            publish_failure(payload, "Sender or receiver not found")
            {:error, {404, "Sender or receiver not found"}}
          end
        rescue
          e ->
            publish_failure(payload, "Internal server error")
            {:error, {500, "Internal server error: #{e}"}}
        end

      {:error, reason} ->
        publish_failure(payload, reason)
        {:error, reason}
    end
  end

  defp create_transaction_approved(payload) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:reduce_balance, fn repo, _changes ->
      reduce_balance(repo, payload.sender, payload.amount)
    end)
    |> Ecto.Multi.run(:increase_balance, fn repo, _changes ->
      increase_balance(repo, payload.receiver, payload.amount, payload.currency)
    end)
    |> Ecto.Multi.run(:register_transaction, fn repo, _changes ->
      register_transaction(repo, payload)
    end)
    |> Repo.transaction()
    |> handle_transaction_result(payload)
  end

  defp handle_transaction_result({:ok, _result}, payload) do
    Producer.publish_to_transactions(%{
      event: "Transaction.Created",
      id: payload.id,
      status: "approved",
      updated_at: DateTime.utc_now(),
      sender: payload.sender,
      receiver: payload.receiver,
      amount: payload.amount,
      currency: payload.currency,
      hash: payload.hash,
      created_at: payload.created_at
    })

    {:ok, %{status: "approved"}}
  end

  defp handle_transaction_result({:error, step, reason, _changes}, payload) do
    Logger.error("Transaction failed at step #{inspect(step)}: #{inspect(reason)}")
    publish_failure(payload, "Transaction failed at step #{inspect(step)}: #{inspect(reason)}")
    {:error, reason}
  end

  defp increase_balance(repo, user_id, amount, currency) do
    user = repo.get!(User, user_id)

    case CurrencyConverter.convert(amount, currency, user.currency) do
      {:ok, converted_amount} ->
        balance_decimal = Decimal.new(user.balance)
        amount_decimal = Decimal.new(Float.to_string(converted_amount))

        new_balance = Decimal.add(balance_decimal, amount_decimal)

        user
        |> User.changeset(%{
          balance: new_balance
        })
        |> repo.update()

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp reduce_balance(repo, user_id, amount) do
    user = repo.get!(User, user_id)

    balance_decimal = Decimal.new(user.balance)
    amount_decimal = Decimal.new(amount)

    if Decimal.compare(balance_decimal, amount_decimal) == :lt do
      {:error, {400, "Bad request: Insufficient balance"}}
    else
      new_balance = Decimal.sub(balance_decimal, amount_decimal)

      case repo.update(User.changeset(user, %{balance: new_balance})) do
        {:ok, updated_user} ->
          {:ok, updated_user}

        {:error, changeset} ->
          {:error, {500, "Internal server error: #{inspect(changeset.errors)}"}}
      end
    end
  end

  defp register_transaction(repo, payload) do
    transaction_payload = %{
      amount: payload.amount,
      currency: payload.currency,
      hash: payload.hash,
      status: "approved",
      sender_id: payload.sender,
      receiver_id: payload.receiver,
      created_at: payload.created_at,
      updated_at: payload.updated_at
    }

    changeset = Transaction.changeset(%Transaction{}, transaction_payload)
    repo.insert(changeset)
  end

  defp create_transaction_pending(payload) do
    Logger.info("Transaction pending: #{inspect(payload)}")
  end

  defp publish_failure(payload, reason) do
    id = UUID.generate()

    Producer.publish_to_transactions(%{
      event: "Transaction.Pending",
      sender: payload.sender,
      receiver: payload.receiver,
      amount: payload.amount,
      currency: payload.currency,
      hash: payload.hash,
      created_at: payload.created_at,
      id: id,
      status: "failed",
      reason: reason,
      updated_at: DateTime.utc_now()
    })
  end
end
