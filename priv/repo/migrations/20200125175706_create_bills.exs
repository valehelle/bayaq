defmodule Bayaq.Repo.Migrations.CreateBills do
  use Ecto.Migration

  def change do
    create table(:bills) do
      add :biller_code, :string
      add :amount, :integer
      add :ref1, :string
      add :bill_id, :string
      add :invoice_id, references(:invoices, on_delete: :nothing)

      timestamps()
    end

    create index(:bills, [:invoice_id])
  end
end
