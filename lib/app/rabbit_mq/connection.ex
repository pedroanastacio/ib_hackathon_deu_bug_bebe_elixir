defmodule App.RabbitMQ.Connection do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    case AMQP.Connection.open("amqp://guest:guest@rabbitmq:5672") do
      {:ok, conn} ->
        {:ok, chan} = AMQP.Channel.open(conn)
        {transactions_queue, users_queue} = declare_queues(chan)
        {:ok, %{connection: conn, channel: chan, transactions_queue: transactions_queue, users_queue: users_queue}}

      {:error, reason} ->
        {:stop, reason}
    end
  end

  defp declare_queues(channel) do
    AMQP.Exchange.declare(channel, "transactions", :fanout, durable: false)
    AMQP.Exchange.declare(channel, "users", :fanout, durable: false)

    {:ok, transactions_queue} = AMQP.Queue.declare(channel, "", exclusive: false)
    {:ok, users_queue} = AMQP.Queue.declare(channel, "", exclusive: false)

    AMQP.Queue.bind(channel, transactions_queue.queue, "transactions")
    AMQP.Queue.bind(channel, users_queue.queue, "users")

    {transactions_queue.queue, users_queue.queue}
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

  def get_queues do
    GenServer.call(__MODULE__, :get_queues)
  end

  def handle_call(:get_channel, _from, %{channel: channel} = state) do
    {:reply, {:ok, channel}, state}
  end

  def handle_call(:get_queues, _from, %{transactions_queue: transactions_queue, users_queue: users_queue} = state) do
    {:reply, {:ok, %{transactions_queue: transactions_queue, users_queue: users_queue}}, state}
  end
end
