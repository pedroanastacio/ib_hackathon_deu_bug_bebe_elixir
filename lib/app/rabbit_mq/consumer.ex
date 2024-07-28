defmodule App.RabbitMQ.Consumer do
  use GenServer
  require Logger

  alias App.RabbitMQ.Connection

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(state) do
    case Connection.get_channel() do
      {:ok, channel} ->
        {:ok, _consumer_tag} = AMQP.Basic.consume(channel, "users")
        {:ok, _consumer_tag} = AMQP.Basic.consume(channel, "transactions")
        {:ok, %{channel: channel, conn: channel.conn}}

      {:error, reason} ->
        {:stop, reason}
    end
  end

  @impl true
  def handle_info({:basic_consume_ok, %{consumer_tag: consumer_tag}}, state) do
    Logger.info("Consumer registered: #{consumer_tag}")
    {:noreply, state}
  end

  def handle_info(
        {:basic_deliver, payload, %{delivery_tag: delivery_tag, routing_key: "users"}},
        state
      ) do
    case state do
      %{channel: channel} ->
        handle_user_message(payload)
        ack_message(channel, delivery_tag)
        {:noreply, state}

      _ ->
        Logger.error("State does not contain :channel key")
        {:noreply, state}
    end
  end

  def handle_info(
        {:basic_deliver, payload, %{delivery_tag: delivery_tag, routing_key: "transactions"}},
        state
      ) do
    case state do
      %{channel: channel} ->
        handle_transaction_message(payload)
        ack_message(channel, delivery_tag)
        {:noreply, state}

      _ ->
        Logger.error("State does not contain :channel key")
        {:noreply, state}
    end
  end

  @impl true
  def handle_info(_msg, state) do
    Logger.info("Received unknown message")
    {:noreply, state}
  end

  defp handle_user_message(payload) do
    Logger.info("Received user message: #{inspect(payload)}")
    # Process the user message
  end

  defp handle_transaction_message(payload) do
    Logger.info("Received transaction message: #{inspect(payload)}")
    # Process the transaction message
  end

  defp ack_message(channel, delivery_tag) do
    AMQP.Basic.ack(channel, delivery_tag)
  end

  def terminate(_reason, %{conn: conn}) do
    AMQP.Connection.close(conn)
  end

  def terminate(_reason, _state) do
    :ok
  end
end
