defmodule App.RabbitMQ.Consumer do
  use GenServer
  require Logger

  alias AMQP.Basic
  alias App.RabbitMQ.Connection
  alias App.Service.{Transaction, User}

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    case Connection.get_channel() do
      {:ok, channel} ->
        case Connection.get_queues() do
          {:ok, %{transactions_queue: transactions_queue, users_queue: users_queue}} ->
            {:ok, _consumer_tag_transactions} =
              Basic.consume(channel, transactions_queue, nil, no_ack: false)

            {:ok, _consumer_tag_users} = Basic.consume(channel, users_queue, nil, no_ack: false)

            {:ok,
             %{channel: channel, transactions_queue: transactions_queue, users_queue: users_queue}}

          {:error, reason} ->
            {:stop, reason}
        end

      {:error, reason} ->
        {:stop, reason}
    end
  end

  def handle_info({:basic_consume_ok, %{consumer_tag: consumer_tag}}, state) do
    Logger.info("Consumer registered: #{consumer_tag}")
    {:noreply, state}
  end

  def handle_info({:basic_deliver, payload, meta}, state) do
    handle_message(payload, meta, state.channel)
    {:noreply, state}
  end

  def handle_info({:basic_cancel_ok, %{consumer_tag: consumer_tag}}, state) do
    Logger.info("Consumer canceled: #{consumer_tag}")
    {:stop, :normal, state}
  end

  def handle_info({:basic_cancel, %{consumer_tag: consumer_tag}}, state) do
    Logger.warn("Consumer canceled by the broker: #{consumer_tag}")
    {:stop, :normal, state}
  end

  def handle_info({:basic_return, payload, meta}, state) do
    Logger.warn("Message returned: #{inspect(meta)} - #{inspect(payload)}")
    {:noreply, state}
  end

  defp handle_message(payload, meta, channel) do
    case meta.exchange do
      "users" ->
        handle_user_message(payload)
        acknowledge_message(channel, meta)

      "transactions" ->
        handle_transaction_message(payload)
        acknowledge_message(channel, meta)

      _ ->
        Logger.info("Unknown exchange: #{meta.exchange}")
        acknowledge_message(channel, meta)
    end
  end

  defp acknowledge_message(channel, %{delivery_tag: delivery_tag}) do
    Basic.ack(channel, delivery_tag)
  end

  defp handle_user_message(payload) do
    Logger.info("Received user message: #{inspect(payload)}")
    User.handle_user_queue_message(payload)
  end

  defp handle_transaction_message(payload) do
    Transaction.create_transaction(payload)
  end
end
