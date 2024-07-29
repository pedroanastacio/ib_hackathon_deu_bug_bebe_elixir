defmodule App.RabbitMQ.Producer do
  alias App.RabbitMQ.Connection
  require Logger

  @users_exchange "users"
  @transactions_exchange "transactions"

  def publish_to_users(message) do
    case Connection.get_channel() do
      {:ok, channel} ->
        AMQP.Basic.publish(channel, @users_exchange, "", message)
        Logger.info("Published message to users queue: #{inspect(message)}")

      {:error, reason} ->
        Logger.error("Failed to get channel for publishing message: #{inspect(reason)}")
    end
  end

  def publish_to_transactions(message) do
    case Connection.get_channel() do
      {:ok, channel} ->
        AMQP.Basic.publish(channel, @transactions_exchange, "", message)
        Logger.info("Published message to transactions queue: #{inspect(message)}")

      {:error, reason} ->
        Logger.error("Failed to get channel for publishing message: #{inspect(reason)}")
    end
  end
end
