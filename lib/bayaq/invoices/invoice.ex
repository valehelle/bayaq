defmodule Bayaq.Invoices.Invoice do
  use Ecto.Schema
  import Ecto.Changeset
  alias Bayaq.Bills.Bill
  schema "invoices" do
    field :status, :string, default: "WAITING_PAYMENT"
    field :stripe_id, :string
    has_many :bills, Bill 
    timestamps()
  end

  @doc false
  def changeset(invoice, attrs) do
    invoice
    |> cast(attrs, [:status, :stripe_id])
    |> validate_required([:status, :stripe_id])
  end
end
