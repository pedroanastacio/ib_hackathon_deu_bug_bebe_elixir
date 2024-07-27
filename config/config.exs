import Config

config :deu_bug_bebe_elixir_ng, App.Repo,
  username: "codefest",
  password: "codefest",
  database: "codefest",
  # Quando rodar localmente, use "localhost"
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :deu_bug_bebe_elixir_ng, ecto_repos: [App.Repo]
