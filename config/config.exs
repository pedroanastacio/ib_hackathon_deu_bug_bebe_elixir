import Config

config :deu_bug_bebe_elixir_ng, App.Repo,
  username: "codefest",
  password: "codefest",
  database: "codefest",
  # Quando rodar localmente, use "localhost"
  hostname: "db",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10,
  private_key: "B1BAC52A0652C1938018AB38EE0820940E9C19A9EA5FFC9D53BD87F6C145A089"

config :deu_bug_bebe_elixir_ng, ecto_repos: [App.Repo]
