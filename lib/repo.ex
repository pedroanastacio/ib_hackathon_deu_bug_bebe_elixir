defmodule App.Repo do
  use Ecto.Repo,
    otp_app: :deu_bug_bebe_elixir_ng,
    adapter: Ecto.Adapters.Postgres
end
