defmodule App.RabbitMQ.Connection do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(state) do
    case AMQP.Connection.open("amqp://guest:guest@rabbitmq:5672") do
      {:ok, conn} ->
        {:ok, chan} = AMQP.Channel.open(conn)
        declare_queues(chan)
        {:ok, %{connection: conn, channel: chan}}

      {:error, reason} ->
        {:stop, reason}
    end
  end

  defp declare_queues(channel) do
    AMQP.Queue.declare(channel, "users", durable: true)
    AMQP.Queue.declare(channel, "transactions", durable: true)
  end

  def get_channel do
    case AMQP.Connection.open("amqp://guest:guest@rabbitmq:5672") do
      {:ok, conn} ->
        {:ok, channel} = AMQP.Channel.open(conn)
        {:ok, channel}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def handle_call(:get_channel, _from, %{channel: channel} = state) do
    {:reply, channel, state}
  end
end
