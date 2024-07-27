defmodule App.Transaction.Enums.Status do
  @moduledoc """
  Defines valid transaction statuses.
  """

  @type t :: :review | :success | :failed | :approved

  @statuses [:review, :success, :failed, :approved]

  @spec all() :: [t()]
  def all, do: @statuses

  @spec valid?(atom) :: boolean
  def valid?(status) when is_atom(status), do: status in @statuses

  def valid?(status) when is_binary(status) do
    status_atom = String.to_existing_atom(status)

    status_atom in @statuses
  rescue
    ArgumentError -> false
  end
end
