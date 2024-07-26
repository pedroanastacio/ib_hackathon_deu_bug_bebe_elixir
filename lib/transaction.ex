defmodule App.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @derive {Jason.Encoder,
           only: [
             :id,
             :sender_id,
             :receiver_id,
             :amount,
             :currency,
             :hash,
             :status,
             :reason,
             :created_at,
             :updated_at
           ]}
  schema "transactions" do
    field(:amount, :decimal)
    field(:currency, :string)
    field(:hash, :string)
    field(:status, :string)
    field(:reason, :string)

    belongs_to(:sender, App.User, type: :binary_id, foreign_key: :sender_id)
    belongs_to(:receiver, App.User, type: :binary_id, foreign_key: :receiver_id)

    timestamps(inserted_at: :created_at)
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:sender_id, :receiver_id, :amount, :currency, :hash, :status, :reason])
    |> validate_required([:sender_id, :receiver_id, :amount, :currency, :hash, :status])
  end
end
