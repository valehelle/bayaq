defmodule Bayaq.Bills.Bill do
  use Ecto.Schema
  import Ecto.Changeset
  alias Bayaq.Invoices.Invoice
  schema "bills" do
    field :amount, Money.Ecto.Amount.Type
    field :bill_id, :string
    field :biller_code, :string
    field :ref1, :string
    belongs_to :invoice, Invoice
    timestamps()
  end

  @doc false
  def changeset(bill, attrs) do
    bill
    |> cast(attrs, [:biller_code, :amount, :ref1, :bill_id])
    |> validate_required([:biller_code, :amount, :ref1, :bill_id])
  end
end
