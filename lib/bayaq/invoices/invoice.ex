defmodule Bayaq.Invoices.Invoice do
  use Ecto.Schema
  import Ecto.Changeset
  alias Bayaq.Bills.Bill
  alias Bayaq.Accounts.User

  schema "invoices" do
    field :status, :string, default: "WAITING_PAYMENT"
    field :stripe_id, :string
    field :amount, Money.Ecto.Amount.Type
    has_many :bills, Bill
    belongs_to :user, User
    timestamps()
  end

  @doc false
  def changeset(invoice, attrs) do
    invoice
    |> cast(attrs, [:status, :stripe_id, :user_id, :amount])
    |> validate_required([:status, :stripe_id, :user_id, :amount])
  end
end
