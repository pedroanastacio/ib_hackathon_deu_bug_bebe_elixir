defmodule AppName.RabbitMQ.Producer do
  alias AppName.RabbitMQ.Connection

  def publish_to_users_queue(message) do
    publish(message, "users")
  end

  def publish_to_transactions_queue(message) do
    publish(message, "transactions")
  end

  defp publish(message, routing_key) do
    {:ok, channel} = Connection.get_channel()
    AMQP.Basic.publish(channel, "", routing_key, message)
  end
end
