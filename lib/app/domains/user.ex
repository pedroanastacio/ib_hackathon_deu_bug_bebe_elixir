defmodule App.Domain.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @derive {Jason.Encoder,
           only: [
             :id,
             :name,
             :email,
             :public_key,
             :status,
             :balance,
             :currency,
             :created_at,
             :updated_at
           ]}
  schema "users" do
    field(:name, :string)
    field(:email, :string)
    field(:public_key, :string)
    field(:status, :string)
    field(:balance, :decimal)
    field(:currency, :string)

    timestamps(inserted_at: :created_at)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :public_key, :status, :balance, :currency])
    |> validate_required([:name, :email, :public_key, :balance])
    |> unique_constraint(:email)
  end
end
