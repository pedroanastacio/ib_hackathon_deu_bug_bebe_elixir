defmodule RabbitMQConnection do
  use GenServer
  use AMQP
  require Logger

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, connect()}
  end

  defp connect do
    # Quando rodar localmente, use "amqp://guest:guest@localhost"
    connection_url = "amqp://guest:guest@rabbitmq:5672"

    case Connection.open(connection_url) do
      {:ok, conn} ->
        case Channel.open(conn) do
          {:ok, chan} ->
            Logger.info("Connected to RabbitMQ and opened channel successfully")
            {:ok, %{connection: conn, channel: chan}}
          {:error, reason} ->
            Logger.error("Failed to open channel: #{inspect(reason)}")
            # Encerra conexão se abertura de canal falhar
            disconnect(conn)
            {:error, reason}
        end
      {:error, reason} ->
        Logger.error("Failed to connect to RabbitMQ: #{inspect(reason)}")
        {:error, reason}
    end
  end

  def disconnect(conn) do
    try do
      Connection.close(conn)
      Logger.info("Successfully disconnected from RabbitMQ")
    rescue
      e in RuntimeError ->
        Logger.error("Failed to disconnect from RabbitMQ: #{inspect(e)}")
    end
  end
end
