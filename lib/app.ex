require Logger

defmodule App do
  use Application

  def start(_type, _args) do
    port = 3000

    children = [
      {Plug.Cowboy, scheme: :http, plug: Router, options: [port: port]},
      App.Repo,
      RabbitMQConnectionSupervisor
    ]

    opts = [strategy: :one_for_one, name: App.Supervisor]

    Logger.info("Server running on port #{Integer.to_string(port)}")

    Supervisor.start_link(children, opts)
  end
end
