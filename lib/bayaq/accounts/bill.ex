defmodule Bayaq.Accounts.Bill do
  use Ecto.Schema
  import Ecto.Changeset
  alias Bayaq.Accounts.User

  schema "user_bills" do
    field :amount, :integer
    field :biller_code, :string
    field :company_name, :string
    field :ref1, :string
    field :ref2, :string
    field :type, :string
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(bill, attrs) do
    bill
    |> cast(attrs, [:ref1, :ref2, :biller_code, :amount, :company_name, :type, :user_id])
    |> validate_required([:ref1, :biller_code, :amount, :company_name, :type, :user_id])
  end
end
