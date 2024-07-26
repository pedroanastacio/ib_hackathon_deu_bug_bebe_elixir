defmodule App.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";"

    create table(:transactions, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :amount, :decimal
      add :currency, :string
      add :hash, :string
      add :status, :string
      add :reason, :string

      add :sender_id, references(:users, type: :uuid, on_delete: :nothing)
      add :receiver_id, references(:users, type: :uuid, on_delete: :nothing)

      timestamps(inserted_at: :created_at)
    end
  end
end
